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
        started:       'startet',
        in_progress:   'pågår',
        ended:         'fullført',
        archived:      'arkivert',
        aborted:       'avbrutt',
        cancelled:     'avbrutt',
        declined:      'avslått',
        disputed:      'avlyst',
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

  def activity_message current_user
    if self.most_recent_activity == :message
      self.messages.last.activity_message current_user
    else

      is_owner = current_user == self.user
      from_name = self.from_user.display_name
      to_name = self.user.display_name

      puts "lsosoosos #{self.status == 'started'}"

    case self.status
      when 'created'
        if is_owner
          "Du har motatt en forespørsel fra #{from_name}."
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
        "Utleietiden er over."
      when 'archived'
        "Leieforholdet er arkivert."
      when 'cancelled'
        if is_owner
          "Du har avbrutt leieforholdet."
        else
          "#{from_name} har avbrutt leieforholdet."
        end
      when 'aborted'
        if is_owner
          "#{from_name} har avbrutt forespørselen."
        else
          "Du har avbrutt forespørselen."
        end
      when 'declined'
        if is_owner
          "Du takket nei til forespørselen fra #{from_name}."
        else
          "#{to_name} takket nei til din forespørsel."
        end
      when 'disputed'
        "Leieforholdet ble avlyst."
      when 'admin_paused'
        "Annonse ble sperret av en administrator."
      end
    end
  end

end