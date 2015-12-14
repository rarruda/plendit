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
    return nil if object.sum_paid_by_renter.nil?
    h.integer_to_decimal( object.sum_paid_by_renter )
  end

  def insurance_amount
    return nil if object.insurance_amount.nil?
    h.integer_to_decimal( object.insurance_amount )
  end

  def platform_fee_amount
    return nil if object.platform_fee_amount.nil?
    h.integer_to_decimal( object.platform_fee_amount )
  end

  def display_status
    status_names = {
        created:       'sendt',
        confirmed:     'godtatt',
        started:       'started',
        in_progress:   'pågår',
        ended:         'ferdig',
        archived:      'arkivert',
        aborted:       'avbrutt',
        cancelled:     'avlyst',
        declined:      'avslått',
        disputed:      'problem',
        admin_paused:  'stoppet av administrator'
    }
    status_names[status.to_sym]
  end

  def display_from_date
    l self.starts_at, format: :plendit_short_date
  end

  def display_end_date
    l self.ends_at, format: :plendit_short_date
  end

end
