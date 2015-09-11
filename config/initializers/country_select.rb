CountrySelect::FORMATS[:with_flag] = lambda do |country|
  "#{country.name}"
  # For when we add flags on the dropdown:
  # (cc:#{country.alpha2}) #{flag(country.alpha2)}"
end