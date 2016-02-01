class User < ActiveRecord::Base
  has_paper_trail only: [ :payment_provider_vid, :birthday, :country_of_residence, :nationality,
    :public_name, :first_name, :last_name, :name, :personhood, :email, :unconfirmed_email,
    :phone_number, :unconfirmed_phone_number, :pays_vat, :status,
    :home_address_line, :home_post_code, :home_city, :home_state ],
    skip: [:encrypted_password, :current_sign_in_at, :remember_created_at, :created_at,
      :confirmation_sent_at, :last_sign_in_at, :phone_number_confirmation_sent_at, :reset_password_sent_at,
      :confirmation_token, :unlock_token, :reset_password_token, :phone_number_confirmation_token]

  rolify

  include SmsVerifiable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :async,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :omniauthable, omniauth_providers: [:facebook, :google, :spid]
  has_many :ads,            dependent: :destroy
  has_many :ad_items,       through: :ads
  has_many :identities,     dependent: :destroy
  has_many :locations,      dependent: :destroy
  has_many :favorite_lists, dependent: :destroy
  has_many :favorite_ads,   through: :favorite_lists
  has_many :user_images,    dependent: :destroy, autosave: true
  has_many :user_documents, dependent: :destroy

  # received_bookings == bookings:
  has_many :bookings,           through: :ad_items
  has_many :sent_bookings,      foreign_key: 'from_user_id', class_name: "Booking"

  has_many :received_feedbacks, foreign_key: 'to_user_id',   class_name: "Feedback"
  has_many :sent_feedbacks,     foreign_key: 'from_user_id', class_name: "Feedback"

  has_many :received_messages,  foreign_key: 'to_user_id',   class_name: "Message"
  has_many :sent_messages,      foreign_key: 'from_user_id', class_name: "Message"

  has_many :notifications,      foreign_key: 'user_id',      class_name: "Notification"

  has_one  :user_payment_account, dependent: :destroy, autosave: true
  has_many :user_payment_cards,   dependent: :destroy


  accepts_nested_attributes_for :user_payment_account, reject_if: proc { |attributes| attributes['bank_account_number'].blank? }
  accepts_nested_attributes_for :user_images, reject_if: proc { |attributes| ( not attributes['user_images_attributes'].nil? ) and attributes['user_images_attributes'].any? { |uia| uia.image_file_name.blank? } }

  validates :unconfirmed_phone_number, presence: true,
    format: { with: /\A[0-9]{8}\z/, message: "Telefonnummeret må være gyldig" },
    if: "unconfirmed_phone_number.present?",
    unless: :new_record?

  validate :validate_unconfirmed_phone_number_is_unique,
    if: "unconfirmed_phone_number.present?",
    unless: :new_record?

  validates :email, presence: true,
    uniqueness: true,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "Epost må være gyldig" }

  #validates :image_url
  validates :about, length: { maximum: 2000, too_long: "Om meg kan inneholde maks %{count} tegn" }

  #only if user has a the bank account number
  validates :nationality,          presence: true, if: :has_bank_account?
  validates :country_of_residence, presence: true, if: :has_bank_account?

  #between 18 and 120 years, only if user has a the bank account number
  validate :birthday, :validate_birthday_is_reasonable, if: :has_bank_account?

  validates :home_address_line, presence: true, if: :has_bank_account?
  validates :home_post_code,    presence: true,
    format: { with: /\A[0-9]{4}\z/, message: "Postnummer må være kun tall. 4 siffer." },
    if: :has_bank_account?

  # NOTE: if the number is invalid for some reason, then the user will not be able to rescue
  #  himself from this bad state:
  validates :personal_id_number,
    uniqueness: { message: "personal_id_number må være unik" },
    if: "personal_id_number.present?",
    unless: :not_verified?

  validates :personal_id_number,
    format: { with: /\A[0-6][0-9][01][0-9][0-9]{2}[0-9]{5}\z/, message: "Personnummer må være gyldig" },
    if: "personal_id_number.present?",
    unless: :not_verified?


  # From: http://edgeapi.rubyonrails.org/classes/ActiveRecord/Enum.html
  # and https://github.com/plataformatec/devise/blob/master/lib/devise/models/confirmable.rb#L99
  # NOTE: confirmed? means email confirmed. phone_confirmed? means phone is confirmed.
  # verified? means both are confirmed and user can interact with other users.
  enum status: { unverified: 1, verified: 2, locked: 3 }

  #natural person, legal_person, legal_organization
  enum personhood: { natural: 0, legal_business: 1, legal_organization: 2 }

  # not_verified: no verification is done.
  # internally_verified: looked at the document internally
  # externally_verified: internally_verified and verified the personal number + name matches against the person registry
  # bankid_verified: active verification against bank_id
  enum verification_level: { not_verified: 0, internally_verified: 2, externally_verified: 3, bankid_verified: 5}

  after_validation :set_city_from_postal_code

  # Set phone confirmation tokens before saving.
  # But only if the unconfirmed phone number was changed to something that isnt blank.
  after_validation :set_phone_attributes,
    if: :unconfirmed_phone_number_changed?,
    if: "unconfirmed_phone_number.present?"

  # Send an SMS if the unconfirmed phone number changed to something that isnt blank.
  before_save :send_sms_for_phone_confirmation,
    if: :unconfirmed_phone_number_changed?,
    if: "unconfirmed_phone_number.present?",
    if: :sms_sending_cool_off_elapsed?


  before_save :set_public_name_from_first_name_on_create, on: :create,
    if: "self.public_name.blank?",
    if: "self.first_name.present?"

  #  * an equivalent callback should be considered, for when updating information:
  after_save :provision_with_mangopay,
    if: :mangopay_provisionable?,
    if: Proc.new { |u| u.payment_provider_vid.blank? ||
        u.payin_wallet_vid.blank? ||
        u.payout_wallet_vid.blank? }

  after_save :refresh_with_mangopay,
    if: :should_trigger_mangopay_refresh?


  after_create :notify_slack_new_user

  # all locations that have been in at least one ad.
  def used_locations
    self.locations.select &:in_use?
  end

  # all locations that have been in at least one ad that isn't excepted_ad
  def used_locations_except excepted_ad
    self.used_locations.reject {|l| l.ads.size == 1 && l.ads.first == excepted_ad }
  end

  def safe_avatar_url
    if self.image_url.blank?
      '/images/no-avatar.png'
    else
      self.image_url
    end
  end

  def safe_display_name
    self.first_name
    # fixme: use decorator
    #( self.personhood == :natural ) ? ( self.first_name.blank? ? self.name : self.first_name ) : self.name
  end

  def verification_level_number
    User.verification_levels[self.verification_level]
  end

  def feedback_score_refresh
    self.attributes = {
      feedback_score:       self.received_feedbacks.size == 0 ? 0 : ( self.received_feedbacks.map(&:score).reduce(0,:+) / self.received_feedbacks.size ),
      feedback_score_count: self.received_feedbacks.size,
    }
    self.feedback_score_updated_at = ( ( self.feedback_score_changed? || self.feedback_score_count_changed? ) ? DateTime.now : self.feedback_score_updated_at )
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

      # Get the existing user by email if the provider gives us an email.
      user = User.where(email: auth.info.email).first if auth.info.email.present?

      # Create the user if it's a new registration (IE, email already not registered in our db)
      if user.nil?
        user = User.create(
          name:        auth.info.name,
          public_name: auth.info.first_name,
          first_name:  auth.info.first_name,
          last_name:   auth.info.last_name,
          email:       auth.info.email,
          image_url:   auth.info.image,
          password:    Devise.friendly_token[0,20],
          personhood:  :natural
        )
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
    self.confirmed?
  end

  def recent_notifications
    self.notifications.includes(:notifiable).order("created_at desc").limit(10)
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
    recv_bookings = self.bookings.includes({ad: [:ad_images]},:messages,:from_user,:user).current_and_pending
    sent_bookings = self.sent_bookings.includes({ad: [:ad_images]},:messages,:from_user,:user).current_and_pending
    bookings = recv_bookings + sent_bookings
    bookings.sort do |a,b| b.updated_at <=> a.updated_at end
  end

  def current_and_recent_bookings days = nil
    days = 2 if days.nil?
    recent = self.bookings
                 .includes({ad: [:ad_images]},:messages,:from_user,:user)
                 .where("bookings.updated_at > ?", days.days.ago)
                 .distinct
    bookings = self.current_bookings + recent
    bookings = bookings.sort do |a,b| b.updated_at <=> a.updated_at end
    bookings = bookings.uniq
  end

  def can_rent? category = nil
    return false unless self.mangopay_provisioned?
    return false unless self.email_verified?
    return false unless self.age.present? && self.age >= 18

    return true if self.phone_verified? && self.has_confirmed_id? && case category
    when 'bap'
      true
    when 'realestate'
      true
    when 'motor'
      self.drivers_license_status == :verified &&
      self.age.present? &&
      self.age >= 23
    when 'boat'
      self.boat_rental_allowed?
    else
      LOG.error message: "can not let anyone rent this item, category unknown: #{category}", user_id: self.id
    end

    false
  end

  def can_rent_out?
    self.mangopay_provisioned? && self.email_verified? && self.phone_verified?
  end

  def drivers_license_status
    d = self.drivers_license
    if d.nil? || d[:front].nil? || d[:back].nil?
      :missing
    elsif d[:front].not_approved? || d[:back].not_approved?
      :rejected
    elsif d[:front].approved? && d[:back].approved?
      :verified
    elsif d[:front].pending_approval? || d[:back].pending_approval?
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
    elsif card.approved?
      :verified
    elsif card.pending_approval?
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

  # either id card or drivers license
  def has_confirmed_id?
    self.internally_verified? || self.externally_verified? || self.bankid_verified?
    # ( User.verification_levels[u.verification_level] > 0 )
    # We now have a verification leveo for the user account, in addition to / coming
    #  from the document verification.
    #[self.id_card_status, self.drivers_license_status].include? :verified
  end

  def has_address?
    [self.home_address_line, self.home_post_code, self.home_city].all?
  end

  def has_bank_account?
    self.user_payment_account.present? && self.user_payment_account.bank_account_number.present?
  end

  def basically_complete?
    [
      self.first_name,
      self.last_name,
      self.email,
      self.birthday,
      self.personhood,
      self.country_of_residence,
      self.nationality,
    ].map(&:present?).all?
  end

  def profile_complete?
    [
      self.first_name,
      self.last_name,
      self.email,
      self.birthday,
      self.personhood,
      self.country_of_residence,
      self.nationality,
      self.current_phone_number,
    ].map(&:present?).all?
  end

  def profile_confirmed?
    self.email_verified? && self.phone_verified?
  end

  def mangopay_provisionable?
    self.profile_complete? && self.profile_confirmed?
  end

  def mangopay_provisioned?
    if self.payment_provider_vid.blank? ||
      self.payin_wallet_vid.blank? ||
      self.payout_wallet_vid.blank?
      LOG.debug message: "profile is NOT fully provisioned with mangopay", user_id: self.id
      false
    else
      #LOG.debug message: "profile IS fully provisioned with mangopay", user_id: self.id
      true
    end
  end

  def fetch_payout_wallet_balance
    return nil unless self.mangopay_provisioned?

    payout_wallet = MangoPay::Wallet.fetch( self.payout_wallet_vid )
    return payout_wallet['Balance']['Amount']
  end

  def boat_license_required?
    !self.birthday.nil? && self.birthday > Date.new(1980, 1, 1)
  end

  def boat_rental_allowed?
    if self.boat_license_required?
      self.seamanship_claimed && self.boat_license_status == :verified
    else
      self.seamanship_claimed
    end
  end

  # in years.
  # from http://stackoverflow.com/questions/10463400/age-calculation-in-ruby
  # NOTE/FIXME: should consider using adroit-age gem.
  def age
    return nil unless self.birthday.present?
    # We use Time.current because each user might be viewing from a
    # different location hours before or after their birthday.
    today = Time.current.to_date

    # If we haven't gotten to their birthday yet this year.
    # We use this method of calculation to catch leapyear issues as
    # Ruby's Date class is aware of valid dates.
    if today.month < self.birthday.month || (today.month == self.birthday.month && self.birthday.day > today.day)
      today.year - self.birthday.year - 1
    else
      today.year - self.birthday.year
    end
  end

  def artificial_guid
    "userid-#{self.id.to_s.rjust(10, '0')}"
  end

  def artificial_guid_for_walletin
    "#{self.artificial_guid}-walletin"
  end

  def artificial_guid_for_walletout
    "#{self.artificial_guid}-walletout"
  end

  private

  def document_rejection_reason category
    document = self.user_documents
      .where(category: category)
      .find { |e| !e.rejection_reason.blank? }
    document.rejection_reason unless document.nil?
  end

  # FIXME: Should happen via a resque Job:
  # UserMangopayCreateJob
  def provision_with_mangopay
    unless self.mangopay_provisionable?
      LOG.error message: "Refuse to provision user. The profile is NOT complete. bailing out.", user_id: self.id
      return false
    end

    if self.payment_provider_vid.blank?
      begin
        if self.natural?
          # https://docs.mangopay.com/api-references/users/natural-users/
          mangopay_user = MangoPay::NaturalUser.create(
            {
              'Tag'         => "user_id=#{self.id} level=#{self.verification_level_number}",
              'PersonType'  => self.personhood,
              'FirstName'   => self.first_name,
              'LastName'    => self.last_name,
              'Email'       => self.email,
              'Birthday'    => self.birthday.strftime('%s').to_i,
              'Nationality' => self.nationality,
              'CountryOfResidence' => self.country_of_residence,
            },
            nil,
            self.artificial_guid,
          );
            #Optional:
            #'Address' => {
            #  'AddressLine1' => self.home_address_line,
            #  'City'         => self.home_city,
            #  'PostalCode'   => self.home_post_code,
            #  'Country'      => self.country_of_residence
            # }
        elsif self.legal_business? or self.legal_organization?
          LOG.error message: "NOT A NATURAL PERSON... Not provisioning user.", user_id: self.id, personhood: self.personhood
          return false

          #code below is NOT TESTED!
          mangopay_personhood_type = {
            legal_business:     'BUSINESS',
            legal_organization: 'ORGANIZATION',
          }

          #https://docs.mangopay.com/api-references/users/legal-users/
          mangopay_user = MangoPay::LegalUser.create(
            {
              'Tag'         => "user_id=#{self.id} level=#{self.verification_level_number}",
              'Name'        => self.name,  #company name
              'Email'       => self.email, #company email
              'LegalPersonType'                => mangopay_personhood_type[self.personhood],
              'LegalRepresentativeFirstName'   => self.first_name,
              'LegalRepresentativeLastName'    => self.last_name,
              'LegalRepresentativeBirthday'    => self.birthday.strftime('%s'),
              'LegalRepresentativeNationality' => self.nationality,
              'LegalRepresentativeCountryOfResidence' => self.country_of_residence,
            },
            nil,
            self.artificial_guid,
          );
            #Optional:
            # 'LegalRepresentativeEmail' =>
            # 'HeadquartersAddress' =>
            # 'LegalRepresentativeAddress' => {
            #    'AddressLine1' =>
            #    'City'         =>
            #    'PostalCode'   =>
            #    'Country'      =>
            # }
        else
          raise 'Invalid personhood'
        end
        LOG.info message: "Response from mangopay: #{mangopay_user}", user_id: self.id
        self.update_columns( payment_provider_vid: mangopay_user['Id'] )
      rescue => e
        LOG.error message: "something has gone wrong with provisioning the user at mangopay. exception: #{e}", user_id: self.id
      end
    end

    if self.payment_provider_vid.present? && ( self.payin_wallet_vid.blank? || self.payout_wallet_vid.blank? )
      # FIXME: should be an active job:
      provision_wallets
    end
  end

  # this method is not throughly tested:
  def provision_wallets
    LOG.info message: "Provisioning wallets with Mangopay", user_id: self.id

    if self.payin_wallet_vid.present? && self.payout_wallet_vid.present?
      LOG.info message: "Wallets already provisioned with Mangopay", user_id: self.id
      return true
    end

    if self.payment_provider_vid.blank?
      LOG.info message: "User not provisioned, can not provision wallets with Mangopay", user_id: self.id
      return false
    end

    begin
      # discover any provisioned wallets:
      wallets = MangoPay::User.wallets( self.payment_provider_vid, {sort: 'CreationDate:asc'} )

      if wallets.present?
        wallet_money_in  = []
        wallet_money_out = []

        wallets.each do |w|
          wallet_money_in  << w['Id'] if w['Description'] == 'money_in'
          wallet_money_out << w['Id'] if w['Description'] == 'money_out'
        end

        self.update_attributes( payin_wallet_vid: wallet_money_in.first)   if wallet_money_in.length  >= 1 && self.payin_wallet_vid.blank?
        self.update_attributes( payout_wallet_vid: wallet_money_out.first) if wallet_money_out.length >= 1 && self.payout_wallet_vid.blank?
      end

      if wallets.blank? || self.payin_wallet_vid.blank? || self.payout_wallet_vid.blank?
        # No wallets present from before, provisioning them:
        if self.payin_wallet_vid.blank?
          # https://docs.mangopay.com/api-references/wallets/
          wallet_in = MangoPay::Wallet.create(
            {
              'Tag'         => "pay_in user_id=#{self.id}",
              'Owners'      => [ self.payment_provider_vid ],
              'Currency'    => PLENDIT_CURRENCY_CODE,
              'Description' => 'money_in',
            },
            nil,
            self.artificial_guid_for_walletin,
          );
          self.update_attributes( payin_wallet_vid: wallet_in['Id'] )
        end

        if self.payout_wallet_vid.blank?
          # https://docs.mangopay.com/api-references/wallets/
          wallet_out = MangoPay::Wallet.create(
            {
              'Tag'         => "pay_out user_id=#{self.id}",
              'Owners'      => [ self.payment_provider_vid ],
              'Currency'    => PLENDIT_CURRENCY_CODE,
              'Description' => 'money_out',
            },
            nil,
            self.artificial_guid_for_walletout,
          );
          self.update_attributes( payout_wallet_vid: wallet_out['Id'] )
        end

      end
    rescue => e
      LOG.error message: "something has gone wrong with fetching/updating/creating wallets at mangopay. exception: #{e}", user_id: self.id
      return nil
    end
  end

  # Update user profile information on mangopay.
  # FIXME: Should happen via a resque Job:
  # UserMangopayRefreshJob // UserMangopayUpdateJob
  def refresh_with_mangopay
    unless self.mangopay_provisionable?
      LOG.error message: "Refuse to provision user. The profile is NOT complete. bailing out.", user_id: self.id
      return false
    end


    if self.payment_provider_vid.present?
      begin
        if self.natural?
          # https://docs.mangopay.com/api-references/users/natural-users/
          mangopay_user = MangoPay::NaturalUser.update( self.payment_provider_vid,
            'Tag'         => "user_id=#{self.id} level=#{self.verification_level_number}",
            #'PersonType'  => self.personhood,
            'FirstName'   => self.first_name,
            'LastName'    => self.last_name,
            'Email'       => self.email,
            'Birthday'    => self.birthday.strftime('%s').to_i,
            'Nationality' => self.nationality,
            'CountryOfResidence' => self.country_of_residence,
          );
            #Optional:
            #'Address' => {
            #  'AddressLine1' => self.home_address_line,
            #  'City'         => self.home_city,
            #  'PostalCode'   => self.home_post_code,
            #  'Country'      => self.country_of_residence
            # }
        elsif self.legal_business? or self.legal_organization?
          LOG.error message: "NOT A NATURAL PERSON... Bailing out!", user_id: self.id, personhood: self.personhood
          return false

          #code below is NOT TESTED!
          mangopay_personhood_type = {
            legal_business:     'BUSINESS',
            legal_organization: 'ORGANIZATION',
          }

          #https://docs.mangopay.com/api-references/users/legal-users/
          mangopay_user = MangoPay::LegalUser.update( self.payment_provider_vid,
            'Tag'         => "user_id=#{self.id} level=#{self.verification_level_number}",
            'Name'        => self.name,  #company name
            'Email'       => self.email, #company email
            'LegalPersonType'                => mangopay_personhood_type[self.personhood],
            'LegalRepresentativeFirstName'   => self.first_name,
            'LegalRepresentativeLastName'    => self.last_name,
            'LegalRepresentativeBirthday'    => self.birthday.strftime('%s'),
            'LegalRepresentativeNationality' => self.nationality,
            'LegalRepresentativeCountryOfResidence' => self.country_of_residence
          );
            #Optional:
            # 'LegalRepresentativeEmail' =>
            # 'HeadquartersAddress' =>
            # 'LegalRepresentativeAddress' => {
            #    'AddressLine1' =>
            #    'City'         =>
            #    'PostalCode'   =>
            #    'Country'      =>
            # }
        else
          raise 'Invalid personhood'
        end
        LOG.info message: "Response from mangopay: #{mangopay_user}", user_id: self.id
      rescue => e
        LOG.error message: "something has gone wrong with provisioning the user at mangopay. exception: #{e}", user_id: self.id
      end
    end
  end

  def should_trigger_mangopay_refresh?
    self.payment_provider_vid.present? &&
    (
      self.first_name_changed? ||
      self.last_name_changed?  ||
      self.email_changed?      ||
      self.birthday_changed?   ||
      self.verification_level_changed?   ||
      self.country_of_residence_changed? ||
      self.nationality_changed?
    )

  end

  def set_public_name_from_first_name_on_create
    self.public_name = self.first_name
  end

  def validate_birthday_is_reasonable
    if self.birthday.nil? || self.birthday < 120.years.ago || self.birthday > 18.years.ago
      errors.add(:birthday, "Du kan ikke være eldre enn 120 eller yngre 18 år gammel. Aldersgrensen for å bli bruker er 18 år.")
    end
  end

  def validate_unconfirmed_phone_number_is_unique
    if User.find_by(phone_number: self.unconfirmed_phone_number).present?
      errors.add(:current_phone_number, "Dette telefonnummeret er koblet til en annen bruker.")
    end
  end

  def set_city_from_postal_code
    self.home_city = POSTAL_CODES[self.home_post_code]
  end

  def notify_slack_new_user
    SlackNotifierJob.perform_later "New user joined: #{self.id} #{self.decorate.display_name} #{self.email}"
  end

end