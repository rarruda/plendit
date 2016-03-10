# http://guides.rubyonrails.org/configuring.html#custom-configuration

#Plendit::Application.config.x.payment_processing.schedule = :daily
#Plendit::Application.config.x.payment_processing.retries  = 3
#Plendit::Application.config.x.super_debugger = true
# read as:
#Rails.configuration.x.super_debugger

include ActionView::Helpers::NumberHelper

# Global Constants:
PLENDIT_COUNTRY_CODE   = 'NO'
PLENDIT_CURRENCY_CODE  = 'NOK'
PLENDIT_COUNTRY_PHONE_CODE = '+47'

POSTAL_CODES = YAML.load_file("#{Rails.root}/config/data/postal_codes.yml")

#Used in google maps API:
COUNTRY_GEO_BOUNDS = [ [57.5,4], [72,32] ]


# "kr 50.000,-"
Plendit::Application.config.x.view.current_num_ads           = number_with_delimiter( 5_000, delimiter: "." )

Plendit::Application.config.x.map.default_bounds             = { ne_lat: 59.97, ne_lon: 10.90, sw_lat: 59.87, sw_lon: 10.61, zl: 13 }
Plendit::Application.config.x.map.google_maps_js_api_key     ='AIzaSyAwciykMKFfGsTiDrqAwg80C5FCSq6vQr8'

Plendit::Application.config.x.customerservice.email          = 'kundesenter@plendit.no'
Plendit::Application.config.x.customerservice.contact_form   = 'https://plendit.zendesk.com/hc/no/requests/new'
Plendit::Application.config.x.customerservice.website        = 'https://plendit.zendesk.com/'
Plendit::Application.config.x.customerservice.insurance_info = 'https://plendit.zendesk.com/hc/no/articles/207314345-Forsikring'
Plendit::Application.config.x.customerservice.privacy_info   = '/privacy'
Plendit::Application.config.x.customerservice.road_assistance_number = '944 36 336'

Plendit::Application.config.x.organization.phone_number      = nil #'+47 97 04 43 99'
Plendit::Application.config.x.organization.address           = 'Plendit AS, Grensen 5-7, 0159 Oslo'
Plendit::Application.config.x.organization.org_id            = '915 252 230'

Plendit::Application.config.x.google.analytics_id            = ( Rails.env == 'production' ) ? 'UA-67449731-1' : 'UA-67449731-2'

Plendit::Application.config.x.platform.fee_in_percent        = 0.10
Plendit::Application.config.x.platform.payout_fee_amount     = 18_00
Plendit::Application.config.x.platform.payout_fee_waived_after_amount = 500_00

# NOTE this value should be lower then 100 EUR. As Mangopay will always require secure mode after 100 EUR.
#  setting it here, and warning the user, is just something nice for our users.
Plendit::Application.config.x.platform.require_secure_mode_after_amount = 500_00

Plendit::Application.config.x.platform.deposit_amount        = {
  bap:           500_00,
  motor:       1_000_00,
  realestate:  1_000_00,
  boat:        1_000_00,
 }

Plendit::Application.config.x.insurance.price_in_percent     = {
  bap:        0.09,
  motor:      0.09,
  realestate: 0.09,
  boat:       0.09,
 }

Plendit::Application.config.x.insurance.deductible_value = {
  bap:         1_500_00,
  motor:      12_000_00,
  realestate:  6_000_00,
  boat:       18_000_00,
 }

Plendit::Application.config.x.insurance.motor_deductible_value = {
  car:     12_000_00,
  caravan: 12_000_00,
  scooter:  6_000_00,
  tractor: 12_000_00,
  vintage_car: 12_000_00,
 }

# Boat does not have a max_coverage_factor, but is insured up to the estimated_value:
Plendit::Application.config.x.insurance.max_coverage_factor = {
  bap:        25,
  motor:      25,
  realestate: 25,
  boat:       0,
 }

# Business rule from IF on how much discount is allowed:
# array of arrays [min_value, max_discount_in_pct], whatever is highest.
Plendit::Application.config.x.insurance.max_discount_after_duration = [
  [   99_00, 0.6 ],
  [  250_00, 0.4 ],
  [ 1000_00, 0.3 ],
 ]

# Business rule from IF on how much discount is allowed:
# array of arrays [min_value, max_discount_in_pct], whatever is highest.
Plendit::Application.config.x.insurance.max_discount_after_duration_boat = [
  [  149_00, 0.3 ]
 ]

Plendit::Application.config.x.insurance.boat_minimum_price_discount_base = 75_00
Plendit::Application.config.x.insurance.boat_minimum_price_discount_multiplier = 0.0025

Plendit::Application.config.x.insurance.boat_owner_premium_threshold = 150_000_00
Plendit::Application.config.x.insurance.boat_max_value = 750_000_00

# should be a hash: bap: 1_500, motor: 1_000_000, realestate: 500_000
Plendit::Application.config.x.insurance.max_insurance_value  = number_to_currency( 1_000_000, unit: 'kr ', delimiter: ".", separator: "," ).gsub(/\,00$/, ",-")

Plendit::Application.config.x.ads.motor_vegvesen_baseurl = "https://www.vegvesen.no/Kjoretoy/Kjop+og+salg/Kj%C3%B8ret%C3%B8yopplysninger?registreringsnummer="

Plendit::Application.config.x.ads.categories = [
  {
    title:       'Stort og smått',
    category:    'bap',
    image:       'category_bap.svg',
    image_width: '36'
  },
  {
    title:       'Kjøretøy og tilhenger',
    category:    'motor',
    image:       'category_vehicle.svg',
    image_width: '42'
  },
  {
    title:       'Hus og hytte',
    category:    'realestate',
    image:       'category_realestate.svg',
    image_width: '36'
  },
  {
    title:       'Båt og kajakk',
    category:    'boat',
    image:       'category_boat.png',
    image_width: '46'
  }
]

Plendit::Application.config.x.frontpage.popular_ads = [
  { title:    'Bil',
    term:     'bil',
    category: 'motor',
    image:    'promo_imgs/bil.jpg'
  },
  { title:    'Bolig',
    term:     '',
    category: 'realestate',
    image:    'promo_imgs/bolig.jpg'
  },
  { title:    'Verktøy',
    term:     'verktøy',
    category: 'bap',
    image:    'promo_imgs/verktoy.jpg'
  },
  { title:    'Scooter',
    term:     'scooter',
    category: 'motor',
    image:    'promo_imgs/scooter.jpg'
  },
  { title:    'Sykkel',
    term:     'sykkel',
    category: 'bap',
    image:    'promo_imgs/sykkel.jpg'
  },
  { title:    'Halloween-kostyme',
    term:     'kostyme',
    category: 'bap',
    image:    'promo_imgs/halloween.jpg'
  }
]

Plendit::Application.config.x.frontpage.hero_videos = [
  {
    still:       'https://cdn.plendit.com/frontpage-videos/with_logo/baatliv_4.jpg',
    still_small: 'https://cdn.plendit.com/frontpage-videos/with_logo/iphone6_plus_baat.jpg',
    mp4:         'https://cdn.plendit.com/frontpage-videos/with_logo/baatliv_4.mp4',
    webm:        'https://cdn.plendit.com/frontpage-videos/with_logo/baatliv_4.webm'
  },
  {
    still:       'https://cdn.plendit.com/frontpage-videos/with_logo/baatliv_5.jpg',
    still_small: 'https://cdn.plendit.com/frontpage-videos/with_logo/iphone6_plus_baat.jpg',
    mp4:         'https://cdn.plendit.com/frontpage-videos/with_logo/baatliv_5.mp4',
    webm:        'https://cdn.plendit.com/frontpage-videos/with_logo/baatliv_5.webm'
  },
  {
    still:       'https://cdn.plendit.com/frontpage-videos/with_logo/sykkel_1.jpg',
    still_small: 'https://cdn.plendit.com/frontpage-videos/with_logo/iphone6_plus_husleie.jpg',
    mp4:         'https://cdn.plendit.com/frontpage-videos/with_logo/sykkel_1.mp4',
    webm:        'https://cdn.plendit.com/frontpage-videos/with_logo/sykkel_1.webm'
  },
  {
    still:       'https://cdn.plendit.com/frontpage-videos/with_logo/hjem_7.jpg',
    still_small: 'https://cdn.plendit.com/frontpage-videos/with_logo/iphone6_plus_husleie.jpg',
    mp4:         'https://cdn.plendit.com/frontpage-videos/with_logo/hjem_7.mp4',
    webm:        'https://cdn.plendit.com/frontpage-videos/with_logo/hjem_7.webm'
  },
  {
    still:       'https://cdn.plendit.com/frontpage-videos/with_logo/husleie_1.jpg',
    still_small: 'https://cdn.plendit.com/frontpage-videos/with_logo/iphone6_plus_husleie.jpg',
    mp4:         'https://cdn.plendit.com/frontpage-videos/with_logo/husleie_1.mp4',
    webm:        'https://cdn.plendit.com/frontpage-videos/with_logo/husleie_1.webm'
  },
]

Plendit::Application.config.x.frontpage.explainer_video_url = 'https://www.youtube.com/embed/mqB032_uek4?rel=0'

Plendit::Application.config.x.facebook_integration = true

Plendit::Application.config.x.purechat_integration = true

Plendit::Application.config.x.signup.bedriftskunde_signup_link = 'https://goo.gl/forms/HkNI7f85XO'
