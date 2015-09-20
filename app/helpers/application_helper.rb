module ApplicationHelper

  def number_to_currency_pretty( num = nil, options = {unit: ''} )
    return '' if num.nil?
    number_to_currency( num, options ).gsub(/\,00 $/, ",- ")
  end

  def integer_to_decimal(num)
    return nil if num.nil?
    #raise if not num.is_a? Integer
    ( ( num / 100).to_i + ( num / 100.0 ).modulo(1) )
  end

  # a copy of ad.to_param, needs to exist to work around ES clients
  #  unwillingness to cooperate. (and so we can generate urls w/o an
  #  extra DB roundtrip)
  def ad_to_param_pretty ad
    #logger.error "to_params >>> #{ad.id}    #{ad.title}"
    if not ad.title.blank?
      [ad.id, ad.title.parameterize].join('----')[0,64]
    else
      ad.id.to_s
    end
  end
end
