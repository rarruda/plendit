module IconHelper
  def icon_verification_ok
    icon 'check-circle-o', 'Godkjent', class: 'fa-fw u-fill-green'
  end

  def icon_verification_pending
    icon 'eye', 'Venter på godkjenning', class: 'fa-fw u-fill-brown'
  end

  def icon_verification_rejected
    icon 'exclamation-triangle', 'Avvist', class: 'fa-fw u-fill-gold'
  end

  def icon_verification_missing
    icon 'plus-circle', 'Last opp', class: 'fa-fw u-fill-gray'
  end

  def icon_verification_required
    icon 'plus-circle', 'Last opp', class: 'fa-fw u-fill-red'
  end
end
