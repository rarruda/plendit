# http://guides.rubyonrails.org/configuring.html#custom-configuration

#Plendit::Application.config.x.payment_processing.schedule = :daily
#Plendit::Application.config.x.payment_processing.retries  = 3
#Plendit::Application.config.x.super_debugger = true


include ActionView::Helpers::NumberHelper

# "kr 50.000,-"
Plendit::Application.config.x.insurance.max_insurance_value  = number_to_currency( 50000, unit: 'kr ', delimiter: ".", separator: "," ).gsub(/\,00$/, ",-")
Plendit::Application.config.x.view.current_num_ads           = number_with_delimiter( 5000, delimiter: "." )

Plendit::Application.config.x.map.default_center_coordinates = { lat: 61.5, lon: 11.0 }
Plendit::Application.config.x.map.default_zoom_level         = 6


Plendit::Application.config.x.customerservice.email          ='NOSPAM__kundesenter@plendit.no'