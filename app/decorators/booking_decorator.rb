class BookingDecorator < Draper::Decorator
  delegate_all
  decorates_association :ad
  decorates_association :user
  decorates_association :from_user
  decorates_association :messages

  # need decorator for sum_paid_to_owner, sum_paid_by_renter
  def sum_paid_to_owner
    return nil if object.sum_paid_to_owner.nil?
    h.integer_to_decimal( object.sum_paid_to_owner )
  end

  def sum_paid_by_renter
    return nil if object.sum_paid_to_owner.nil?
    h.integer_to_decimal( object.sum_paid_to_owner )
  end
end
