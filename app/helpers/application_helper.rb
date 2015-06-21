module ApplicationHelper

  def number_to_currency_pretty( num )
    number_to_currency( num, unit: '' ).gsub(/\,00 /, ",- ")
  end
end
