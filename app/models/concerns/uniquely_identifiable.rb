module UniquelyIdentifiable
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  included do
    validates :guid, presence: true, uniqueness: true

    before_create :set_guid
  end

  def to_params
    self.guid
  end

  private
  def set_guid
      self.guid ||= loop do
        # for a shorter string use:
        # generated_guid = SecureRandom.random_number(2**122).to_s(36)
        generated_guid = SecureRandom.uuid
        break generated_guid unless self.class.exists?(guid: generated_guid)
      end
  end
end