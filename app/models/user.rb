class User < ActiveRecord::Base
  has_paper_trail :only => [ :payment_provider_vid, :birthday, :country_of_residence, :nationality,
    :first_name, :last_name, :name, :personhood, :email, :unconfirmed_email,
    :phone_number, :unconfirmed_phone_number, :pays_vat, :status,
    :home_address_line, :home_post_code, :home_city, :home_state ],
    :skip => [:encrypted_password, :current_sign_in_at, :remember_created_at, :created_at,
      :confirmation_sent_at, :last_sign_in_at, :phone_number_confirmation_sent_at, :reset_password_sent_at,
      :confirmation_token, :unlock_token, :reset_password_token, :phone_number_confirmation_token]

  rolify

  include SmsVerifiable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: [:facebook, :google, :spid]
  has_many :ads, dependent: :destroy
  has_many :ad_items, :through => :ads
  has_many :identities
  has_many :locations
  has_many :favorite_lists
  has_many :favorite_ads, :through => :favorite_lists
  has_many :user_images, dependent: :destroy, autosave: true
  has_many :user_documents

  # received_bookings == bookings:
  has_many :bookings, :through => :ad_items
  has_many :sent_bookings, foreign_key: 'from_user_id', :class_name => "Booking"

  has_many :received_feedbacks, :through => :ads, :class_name => "Feedback"
  has_many :sent_feedbacks, foreign_key: 'from_user_id', :class_name => "Feedback"

  has_many :received_messages, foreign_key: 'to_user_id', :class_name => "Message"
  has_many :sent_messages, foreign_key: 'from_user_id', :class_name => "Message"

  has_many :notifications, foreign_key: 'user_id', :class_name => "Notification"

  has_one  :user_payment_account, dependent: :destroy, autosave: true
  has_many :user_payment_cards


  accepts_nested_attributes_for :user_payment_account, :reject_if => proc { |attributes| attributes['bank_account_number'].blank? }
  accepts_nested_attributes_for :user_images, :reject_if => proc { |attributes| ( not attributes['user_images_attributes'].nil? ) and attributes['user_images_attributes'].any? { |uia| uia.image_file_name.blank? } }


  #validates :phone_number, presence: true,
  #  format: { with: /\A[0-9]{8}\z/, message: "valid 8 digit mobile number required" },
  #  :unless => proc { |a| a['phone_number'].blank? }
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "må være gyldig" }

  #validates :image_url

  #only if user has a the bank account number
  validates :nationality,          presence: true, :if => :has_bank_account?
  validates :country_of_residence, presence: true, :if => :has_bank_account?

  #between 10 and 120 years, only if user has a the bank account number
  validate :birthday, :birthday_should_be_reasonable, :if => :has_bank_account?

  validates :home_address_line, presence: true, :if => :has_bank_account?
  validates :home_post_code,    presence: true, format: { with: /\A[0-9]{4,8}\z/, message: "må være kun tall. 4-8 siffer." }, :if => :has_bank_account?



  # From: http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html
  # and https://github.com/plataformatec/devise/blob/master/lib/devise/models/confirmable.rb#L99
  # NOTE: confirmed? means email confirmed. phone_confirmed? means phone is confirmed.
  # verified? means both are confirmed and user can interact with other users.
  enum status: { unverified: 1, verified: 2, locked: 3 }

  #natural person, legal_person, legal_organization
  enum personhood: { natural: 0, legal_business: 1, legal_organization: 2 }


  after_validation :set_city_from_postal_code

  # Set phone confirmation tokens before saving.
  # But only if the unconfirmed phone number was changed to something that isnt blank.
  after_validation :set_phone_attributes,
    if: :unconfirmed_phone_number_changed?,
    unless: "unconfirmed_phone_number.blank?"

  # Send an SMS if the unconfirmed phone number changed to something that isnt blank.
  before_save  :send_sms_for_phone_confirmation,
    if: :unconfirmed_phone_number_changed?,
    unless: "unconfirmed_phone_number.blank?",
    if: :sms_sending_cool_off_elapsed?

  #  * an equivalent callback should be considered, for when updating information:
  after_save :provision_with_mangopay,
    if: :mangopay_provisionable?,
    if: :email_verified?,
    if: :phone_verified?,
    if: Proc.new { |u| u.payment_provider_vid.blank? ||
        u.user_payment_account.nil? ||
        u.payin_wallet_vid.blank? ||
        u.payout_wallet_vid.blank? }
        # same as: unless: :mangopay_provisioned?




  def safe_avatar_url
    # Gravatar: "http://gravatar.com/avatar/#{Digest::MD5.hexdigest(self.email.strip.downcase)}?r=pg&d=mm" ### &d=#{our_own_generic_profile_image_url}
    # Gravatar SSL: "http://secure.gravatar.com/..."
    if self.image_url.blank?
      ( Rails.env.production? ?  "/images/default_avatar.png" : "http://robohash.org/#{Digest::MD5.hexdigest(self.email.strip.downcase)}?gravatar=hashed&bgset=any" )
    else
      self.image_url
    end
  end

  def safe_display_name
    self.first_name
    # fixme: use decorator
    #( self.personhood == :natural ) ? ( self.first_name.blank? ? self.name : self.first_name ) : self.name
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

      email_is_verified = false

      case auth.provider
      when 'facebook'
        email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email || auth.extra.raw_info.email_verified)
      when 'spid'
        #email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email || auth.extra.raw_info.email_verified)
        auth.extra.raw_info.emails.each{ |e|
          email_is_verified = true if e.value == auth.info.email and e.verified
        }
        # or could be done by checking that emailVerified is not 0000 or after sometime in 2000.
      when 'google'
        email_is_verified = true if [true, "true"].include? auth.extra.raw_info.email_verified
      else
        email_is_verified = false
      end

      email = auth.info.email if email_is_verified
      user = User.where(:email => email).first if email


      #
      # We need serious refactoring.
      #


      # Create the user if it's a new registration (IE, email already not registered in our db)
      if user.nil?
        user = User.new(
          name: auth.info.name,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          #birthday: auth.info.birthday, #<-- not sure all oauth providers provide this field... possibly different formats too.
          email: email ? email : "temp-#{auth.uid}@#{auth.provider}.com",
          image_url: auth.info.image,
          password: Devise.friendly_token[0,20],
          personhood: :natural
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

  def email_verified?
    self.email.present? &&
    !self.email.start_with?('temp-') &&
    ( self.unconfirmed_email.blank? || self.unconfirmed_email == self.email)
  end

  def recent_notifications
    self.notifications.order("created_at desc").limit(10)
  end

  def unseen_notifications_count
    self.notifications.fresh.size
  end

  def owns_booking_item?(booking)
    self == booking.ad.user
  end

  def owns_ad?(ad)
    self == ad.user
  end

  def favorite_location
    self.locations.where(favorite: true).first || self.locations.first
  end

  def set_favorite_location(location)
    Location.transaction do
      location.update(favorite: true)
      self.locations.where.not(id: location.id).each { |l| l.update(favorite: false) }
    end
  end

  def is_site_admin?
    self.has_role? :site_admin
  end

  def connected_to_provider(provider_id)
    self.identities.exists?(provider: provider_id)
  end

  def current_bookings
    recv_bookings = self.bookings.current
    sent_bookings = self.sent_bookings.current
    bookings = recv_bookings + sent_bookings
    bookings.sort do |a,b| b.updated_at <=> a.updated_at end
  end

  #generic methods. we also need more specific versions which restrict based on documents:
  # if renting a car: valid drivers license and age check.
  # kyc rules being respected
  def can_rent?
    self.mangopay_provisioned?
  end

  def can_rent_out?
    self.mangopay_provisioned?
  end

  def drivers_license_status
    d = self.drivers_license
    if d.nil? || d[:front].nil? || d[:back].nil?
      :missing
    elsif d[:front].status == 'not_approved' || d[:back].status == 'not_approved'
      :rejected
    elsif d[:front].status == 'approved' && d[:back].status == 'approved'
      :verified
    elsif d[:front].status == 'pending_approval' || d[:back].status == 'pending_approval'
      :pending
    else
      :rejected # probably not good enough
    end
  end

  def delete_current_drivers_license
    self.user_documents
      .where(category: [ UserDocument.categories[:drivers_license_front], UserDocument.categories[:drivers_license_back] ])
      .destroy_all
  end

  def drivers_license
    sides = {
      front: self.user_documents.find_by(category: UserDocument.categories[:drivers_license_front]),
      back:  self.user_documents.find_by(category: UserDocument.categories[:drivers_license_back])
    }
    sides if sides.size == 2 && sides.none? { |k, v| v.nil? }
  end

  def drivers_license_rejection_reason
    document_rejection_reason([
      UserDocument.categories[:drivers_license_front],
      UserDocument.categories[:drivers_license_back]
    ])
  end

  def delete_current_id_card
    self.user_documents.where(category: UserDocument.categories[:id_card]).destroy_all
  end

  def id_card_status
    card = self.id_card
    if card.nil?
      :missing
    elsif card.status == 'approved'
      :verified
    elsif card.status == 'pending_approval'
      :pending
    else
      :rejected # probably not good enough
    end
  end

  def id_card
    self.user_documents.find_by(category: UserDocument.categories[:id_card])
  end

  def id_card_rejection_reason
    document_rejection_reason(UserDocument.categories[:id_card])
  end

  def delete_current_boat_license
    self.user_documents.where(category: UserDocument.categories[:boat_license]).destroy_all
  end

  def boat_license_status
    card = self.boat_license
    if card.nil?
      :missing
    elsif card.status == 'approved'
      :verified
    elsif card.status == 'pending_approval'
      :pending
    else
      :rejected # probably not good enough
    end
  end

  def boat_license
    self.user_documents.find_by(category: UserDocument.categories[:boat_license])
  end

  def boat_license_rejection_reason
    document_rejection_reason(UserDocument.categories[:boat_license])
  end

  def has_address?
    [self.home_address_line, self.home_post_code, self.home_city].all?
  end

  def has_bank_account?
    self.user_payment_account.present? && self.user_payment_account.bank_account_number
  end

  # Same as in MangopayService:
  # mangopay_provisionable?
  def profile_complete?
    [
      self.first_name,
      self.last_name,
      self.email,
      self.birthday,
      self.personhood,
      self.country_of_residence,
      self.nationality,
      self.phone_number,
      self.email
    ].all?
  end
  alias_method :mangopay_provisionable?, :profile_complete?

  def mangopay_provisioned?
    if self.payment_provider_vid.blank? ||
      self.payin_wallet_vid.blank? ||
      self.payout_wallet_vid.blank?
      LOG.error "profile is NOT fully provisioned with mangopay", {user_id: self.id}
      false
    else
      LOG.error "profile IS fully provisioned with mangopay", {user_id: self.id}
      true
    end
  end

  private

  def document_rejection_reason category
    document = self.user_documents
      .where(category: category)
      .find { |e| !e.rejection_reason.blank? }
    document.rejection_reason if !document.nil?
  end

  def provision_with_mangopay
    # instantiating mangopay service:
    mangopay = MangopayService.new( self )

    if self.payment_provider_vid.blank?
      mangopay.provision_user
    end

    if ( ! self.payment_provider_vid.blank? ) && ( self.payin_wallet_vid.blank? || self.payout_wallet_vid.blank? )
      mangopay.provision_wallets
    end
  end


  def birthday_should_be_reasonable
    if self.birthday.nil? || self.birthday < 120.years.ago || self.birthday > 14.years.ago
      errors.add(:birthday, "you can not be older then 120, and can not be younger then 14.")
    end
  end

  def set_city_from_postal_code
    self.home_city = POSTAL_CODES[self.home_post_code]
  end

end