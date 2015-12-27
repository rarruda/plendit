module ApplicationHelper

  #FIXME: this should be made much prettier. sorta hackish the way it is.

  # takes an internal monetary value, (that is one that is integer),
  # the actual value multiplied by 100, and prints it as a Norwegian
  # localized currency string
  def format_monetary_full val
    f = integer_to_decimal val
    number_to_currency f, locale: :nb
  end

  def format_monetary_full_pretty val
    f = integer_to_decimal val
    number_to_currency_pretty f, locale: :nb
  end

  # this method just makes a decimal number pretty / formatted correctly:
  # input is expected to be in Decimal format already! ( eg: 123.45 )
  # FIXME: THIS METHOD SHOULD NOT TO BE USED DIRECTLY IN A VIEW.
  def number_to_currency_pretty( num = nil, options = {unit: '', locale: :nb} )
    return '' if num.nil?
    number_to_currency( num, options ).gsub(',00 ', ',- ')
  end

  # takes the internal integer monetary representation: 1043 and converts
  #  and converts it to the a decimal (humanly formatted number, eg: 10.43)
  def integer_to_decimal(i_num)
    return nil if i_num.nil?
    #raise if not i_num.is_a? Integer
    ( ( i_num / 100).to_i + ( i_num / 100.0 ).modulo(1) )
  end

  # takes a decimal (humanly formatted number, eg: 10.43) and converts to
  #  the internal integer monetary representation: 1043.
  def decimal_to_integer(d_num)
    ( d_num.to_f * 100 ).to_i
  end

  # a copy of ad.to_param, needs to exist to work around ES clients
  #  unwillingness to cooperate. (and so we can generate urls w/o an
  #  extra DB roundtrip)
  def ad_to_param_pretty ad
    #LOG.error "to_params >>> #{ad.id}    #{ad.title}"
    if not ad.title.blank?
      [ad.id, ad.title.parameterize].join('--')[0,64]
    else
      ad.id.to_s
    end
  end
end
