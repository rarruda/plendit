class UserPaymentCard < ActiveRecord::Base
  has_paper_trail #:ignore => [:access_key, :preregistration_data, :registration_data, :card_registration_url]


  belongs_to :user


  # Never show "deleted" cards. (inactive)
  default_scope { where.not( active_mp: false ) } #either true or nil.
  #user_id: current_user.id,
  #FIXME: dont ever show cards that belong to other users...

  validates_uniqueness_of :guid


  before_validation :set_guid, :on => :create



  def to_param
    self.guid
  end

  private

  def set_guid
    self.guid = loop do
      generated_guid = SecureRandom.uuid
      break generated_guid unless self.class.exists?(guid: generated_guid)
    end
  end
end
