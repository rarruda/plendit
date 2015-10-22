module VerificationHelper

  def verification_state_label state
    cls = 'verification-state-label'
    case state
    when :required
      content_tag :span, 'REQWERD', class: "#{cls} #{cls}--required"
    when :missing
      content_tag :span, '(ikke verifisert)', class: "#{cls} #{cls}--missing"
    when :verified
      content_tag :span, icon_verification_ok, class: "#{cls} #{cls}--verified"
    when :rejected
      content_tag :span, icon_verification_rejected, class: "#{cls} #{cls}--rejected"
    when :pending
      content_tag :span, icon_verification_pending, class: "#{cls} #{cls}--pending"
    else
      ''
    end
  end

end
