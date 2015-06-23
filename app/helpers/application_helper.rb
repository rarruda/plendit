module ApplicationHelper

  def number_to_currency_pretty( num, options = {unit: ''} )
    number_to_currency( num, options ).gsub(/\,00 /, ",- ")
  end
end
