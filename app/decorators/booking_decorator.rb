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
      created:           'venter på svar',
      payment_preauthorized: 'venter på svar',
      confirmed:         'godtatt',
      payment_confirmed: 'godtatt',
      started:           'pågår',
      in_progress:       'pågår',
      ended:             'fullført',
      archived:          'arkivert',
      aborted:           'avlyst',
      cancelled:         'avlyst',
      declined:          'avslått',
      payment_preauthorization_failed: 'betaling mislyktes',
      payment_failed:    'betaling mislyktes',
      disputed:          'avbrutt',
      dispute_agree:     'avbrutt',
      dispute_diaagree:  'avbrutt',
      admin_paused:      'stoppet av administrator',
    }
    status_names[status.to_sym]
  end

  def display_from_date
    l self.starts_at, format: :plendit_short_date
  end

  def display_end_date
    l self.ends_at, format: :plendit_short_date
  end

  def activity_message current_user
    if self.most_recent_activity == :message
      self.messages.last.activity_message current_user
    else

      is_owner  = ( current_user == self.user )
      from_name = self.from_user.display_name
      to_name   = self.user.display_name


    case self.status
      when 'created'
        if is_owner
          "Du har mottatt en forespørsel fra #{from_name}."
        else
          "Du har sendt en forespørsel til #{to_name}."
        end
      when 'confirmed'
        if is_owner
          "Du har godtatt forespørselen fra #{from_name}."
        else
          "#{to_name} har godtatt forespørselen din."
        end
      when 'started'
        "Utleieperioden starter snart."
      when 'in_progress'
        "Utleietiden har startet."
      when 'ended'
        "Utleieperioden er over."
      when 'archived'
        "Leieforholdet er arkivert."
      when 'cancelled'
        if is_owner
          "Du har avlyst leieforholdet."
        else
          "#{from_name} har avlyst leieforholdet."
        end
      when 'aborted'
        if is_owner
          "#{from_name} har avlyst forespørselen."
        else
          "Du har avlyst forespørselen."
        end
      when 'declined'
        if is_owner
          "Du takket nei til forespørselen fra #{from_name}."
        else
          "#{to_name} takket nei til din forespørsel."
        end
      when 'disputed'
        "Leieforholdet ble avbrutt."
      when 'admin_paused'
        "Annonse ble sperret av en administrator."
      end
    end
  end

  def booking_title_for user
    if self.was_ever_confirmed?
      if user.owns_booking_item? self
        "Leieforhold med #{self.from_user.display_name}"
      else
        "Leieforhold med #{self.ad.user.display_name}"
      end
    else
      if user.owns_booking_item? self
        "Leieforespørsel fra #{self.from_user.display_name}"
      else
        "Leieforespørsel til #{self.ad.user.display_name}"
      end
    end
  end

end