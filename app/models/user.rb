class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: [:facebook]
  has_many :ads, dependent: :destroy
  has_many :ad_items, :through => :ads
  has_many :identities
  has_many :locations
  has_many :favorite_lists
  has_many :favorite_ads, :through => :favorite_lists

  # received_bookings == bookings:
  has_many :bookings, :through => :ad_items
  has_many :sent_bookings, foreign_key: 'from_user_id', :class_name => "Booking"

  has_many :received_feedbacks, :through => :ads, :class_name => "Feedback"
  has_many :sent_feedbacks, foreign_key: 'from_user_id', :class_name => "Feedback"

  has_many :received_messages, foreign_key: 'to_user_id', :class_name => "Message"
  has_many :sent_messages, foreign_key: 'from_user_id', :class_name => "Message"

  has_many :notifications, foreign_key: 'user_id', :class_name => "Notification"

  validates :name, presence: true
  #validates :phone_number, presence: true, format: { with: /\A[0-9]{8}\z/, message: "only allows numbers" }
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "valid email required" }

  #validates :image_url

  enum status: { unconfirmed: 1, confirmed: 2, locked: 3, admin: 10 }


  # only act on the phone settings, if the phone number was changed.
  # TODO: add trigger so that its possible to re-send codes for the current unverified phone number.
  before_save :set_phone_attributes,
    if: :phone_pending_confirmation?,
    if: :phone_pending_changed?,
    if: :phone_not_changed?

  after_save  :send_sms_for_phone_confirmation,
    if: :phone_pending_confirmation?,
    if: :phone_pending_changed?,
    if: :phone_not_changed?


  def avatar_url_safetest
    ##self.image_url || self.identities.find_by_provider('facebook').image_url || "http://robohash.org/#{Digest::MD5.hexdigest(self.email.strip.downcase)}?gravatar=hashed&bgset=any"
    self.image_url || "http://robohash.org/#{Digest::MD5.hexdigest(self.email.strip.downcase)}?gravatar=hashed&bgset=any"
  end


  def calculate_average_rating
    if self.received_feedbacks.size == 0
      return 0
    end

    i   = 0
    sum = 0
    self.received_feedbacks.each do |fb|
      i   += 1
      sum += fb.score
    end
    ( sum / i )
  end

  def recent_feedback
    received_feedbacks[0..3]
  end

  # supporting multiple OAuth identities:
  #  see: http://sourcey.com/rails-4-omniauth-using-devise-with-twitter-facebook-and-linkedin/
  def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user

    # Create the user if needed
    if user.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email || auth.extra.raw_info.email_verified)
      email = auth.info.email if email_is_verified
      user = User.where(:email => email).first if email

      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          name: auth.info.name, ##auth.extra.raw_info.name,
          email: email ? email : "temp-#{auth.uid}@#{auth.provider}.com",
          image_url: auth.info.image,
          password: Devise.friendly_token[0,20]
        )
        user.skip_confirmation! ###### <== funny business of skipping confimation even if we have an invalid email.
        ############################## we probably to always have an email confirmed.
        user.save!
      end
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end


  # ugh, this is soooo ugly! Look at app/views/users/confirmations/new.html.erb
  def email_verified?
    self.email && self.email !~ /\Atemp-/
  end

  def new_notifications()
    # todo: use status flag to only return unread notifications
    self.notifications.order("updated_at desc")
  end



  def current_phone_number
    self.unconfirmed_phone_number || self.phone_number
  end

  # do all transformations for phone_number confirmation.
  def confirm_phone_number!
    if self.unconfirmed_phone_number.nil?
      logger.tagged("user_id:#{self.id}") {
        logger.error "tried to confirm an unconfirmed_phone_number that is nil. This should never happen."
      }
      nil
    else
      self.phone_number              = self.unconfirmed_phone_number
      self.unconfirmed_phone_number  = nil
      self.phone_number_confirmed_at = Time.now
      self.phone_number_confirmation_token = nil

      self.save!
    end
  end

  # is_phone_pending_confirmation?
  def phone_pending_confirmation?
    not unconfirmed_phone_number.nil?
  end

  def phone_pending_changed?
    unconfirmed_phone_number_changed?
  end

  def phone_not_changed?
    not phone_number_changed?
  end

  private
  def set_phone_attributes
    #self.phone_number = false
    # 6 digit zero padded number as a string.
    self.phone_number_confirmation_token = ( SecureRandom.hex(3).to_i(16) % 1000000 ).to_s.rjust( 6, "0" )
    # removes all white spaces, hyphens, and parenthesis
    self.unconfirmed_phone_number.to_s.gsub!(/[\s\-\(\)]+/, '')
  end

  def send_sms_for_phone_confirmation
    PhoneVerificationService.new( user_id: id ).process
  end



end