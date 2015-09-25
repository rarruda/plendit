CountrySelect::FORMATS[:with_flag] = lambda do |country|
  country_name = country.translations[I18n.locale.to_s] || country.name
  "#{country_name}"
  # For when we add flags on the dropdown:
  #"(cc:#{country.alpha2}) #{flag(country.alpha2)} country_name"
end