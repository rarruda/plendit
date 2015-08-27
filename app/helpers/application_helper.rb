module ApplicationHelper

  def number_to_currency_pretty( num, options = {unit: ''} )
    number_to_currency( ( num || '' ), options ).gsub(/\,00 /, ",- ")
  end

  # a copy of ad.to_param, needs to exist to work around ES clients
  #  unwillingness to cooperate. (and so we can generate urls w/o an
  #  extra DB roundtrip)
  def ad_to_param_pretty ad
    #logger.error "to_params >>> #{ad.id}    #{ad.title}"
    if not self.title.blank?
      [self.id, self.title.parameterize].join('----')[0,64]
    else
      self.id.to_s
    end
  end
end
