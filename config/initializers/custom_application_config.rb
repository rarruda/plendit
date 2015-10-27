# http://guides.rubyonrails.org/configuring.html#custom-configuration

#Plendit::Application.config.x.payment_processing.schedule = :daily
#Plendit::Application.config.x.payment_processing.retries  = 3
#Plendit::Application.config.x.super_debugger = true
# read as:
#Rails.configuration.x.super_debugger

include ActionView::Helpers::NumberHelper

# Global Constants:
PLENDIT_COUNTRY_CODE  = 'NO'
PLENDIT_CURRENCY_CODE = 'NOK'
PLENDIT_COUNTRY_PHONE_CODE = '+47'

POSTAL_CODES = YAML.load_file("#{Rails.root}/config/data/postal_codes.yml")

#Used in google maps API:
COUNTRY_GEO_BOUNDS = [ [57.5,4], [72,32] ]

# beta if hostname has this pattern:
Plendit::Application.config.x.application_mode.beta = ( `hostname` =~ /^sbox-plendit-web/ )

# "kr 50.000,-"
Plendit::Application.config.x.view.current_num_ads           = number_with_delimiter( 5_000, delimiter: "." )

Plendit::Application.config.x.map.default_bounds             = { ne_lat: 59.97, ne_lon: 10.90, sw_lat: 59.87, sw_lon: 10.61, zl: 13 }
Plendit::Application.config.x.map.google_maps_js_api_key     ='AIzaSyAwciykMKFfGsTiDrqAwg80C5FCSq6vQr8'

Plendit::Application.config.x.customerservice.email          = 'kundesenter@plendit.no'
Plendit::Application.config.x.customerservice.contact_form   = 'https://plendit.zendesk.com/hc/no/requests/new'
Plendit::Application.config.x.customerservice.website        = 'https://plendit.zendesk.com/'
Plendit::Application.config.x.customerservice.insurance_info = 'https://plendit.zendesk.com/hc/no/articles/204988442-Hvordan-fungerer-forsikringen-'
Plendit::Application.config.x.customerservice.privacy_info   = '#'

Plendit::Application.config.x.organization.phone_number      = nil #'+47 97 04 43 99'
Plendit::Application.config.x.organization.address           = 'Plendit AS, Grensen 5-7, 0159 Oslo'
Plendit::Application.config.x.organization.org_id            = '915 252 230'

Plendit::Application.config.x.google.analytics_id            = ( Rails.env == 'production' ) ? 'UA-67449731-1' : 'UA-67449731-2'

Plendit::Application.config.x.platform.fee_in_percent        = 0.10
Plendit::Application.config.x.insurance.price_in_percent     = {
  bap:        0.08,
  motor:      0.09,
  realestate: 0.09
 }

Plendit::Application.config.x.insurance.reservation_value   = {
  bap:         0,
  motor:       1_000_00,
  realestate:  0
 }

Plendit::Application.config.x.insurance.deductible_value = {
  bap:         1_500_00,
  motor:      12_000_00,
  realestate: 12_000_00
 }

Plendit::Application.config.x.insurance.is_required = {
  bap:        false,
  motor:      true,
  realestate: true
}

# should be a hash: bap: 1_500, motor: 1_000_000, realestate: 500_000
Plendit::Application.config.x.insurance.max_insurance_value  = number_to_currency( 1_000_000, unit: 'kr ', delimiter: ".", separator: "," ).gsub(/\,00$/, ",-")

Plendit::Application.config.x.ads.categories = [
  {
    title:    'Stort og smått',
    category: 'bap',
    image:    'category_bap.png'
  },
  {
    title:    'Kjøretøy',
    category: 'motor',
    image:    'category_vehicle.png'
  },
  {
    title:    'Eiendom',
    category: 'realestate',
    image:    'category_realestate.png'
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
  # båtliv
  {
    still: 'http://cdn.plendit.com/frontpage-videos/baatliv_3_still.jpg',
    mp4:   'http://cdn.plendit.com/frontpage-videos/baatliv_3.mp4',
    webm:  'http://cdn.plendit.com/frontpage-videos/baatliv_3.webm'
  },
  {
    still: 'http://cdn.plendit.com/frontpage-videos/baatliv_4_still.jpg',
    mp4:   'http://cdn.plendit.com/frontpage-videos/baatliv_4.mp4',
    webm:  'http://cdn.plendit.com/frontpage-videos/baatliv_4.webm'
  },
  {
    still: 'http://cdn.plendit.com/frontpage-videos/baatliv_5_still.jpg',
    mp4:   'http://cdn.plendit.com/frontpage-videos/baatliv_5.mp4',
    webm:  'http://cdn.plendit.com/frontpage-videos/baatliv_5.webm'
  },

  # hjem
  {
    still: 'http://cdn.plendit.com/frontpage-videos/hjem_1.jpg',
    mp4:   'http://cdn.plendit.com/frontpage-videos/hjem_1.mp4',
    webm:  'http://cdn.plendit.com/frontpage-videos/hjem_1.webm'
  },
  {
    still: 'http://cdn.plendit.com/frontpage-videos/hjem_2_still.jpg',
    mp4:   'http://cdn.plendit.com/frontpage-videos/hjem_2.mp4',
    webm:  'http://cdn.plendit.com/frontpage-videos/hjem_2.webm'
  },
  {
    still: 'http://cdn.plendit.com/frontpage-videos/hjem_7.jpg',
    mp4:   'http://cdn.plendit.com/frontpage-videos/hjem_7.mp4',
    webm:  'http://cdn.plendit.com/frontpage-videos/hjem_7.webm'
  },
  {
    still: 'http://cdn.plendit.com/frontpage-videos/hjem_8.jpg',
    mp4:   'http://cdn.plendit.com/frontpage-videos/hjem_8.mp4',
    webm:  'http://cdn.plendit.com/frontpage-videos/hjem_8.webm'
  },
]

Plendit::Application.config.x.frontpage.explainer_video_url = 'https://www.youtube.com/embed/mqB032_uek4?rel=0'

Plendit::Application.config.x.footer.show_facebook_buttons = Plendit::Application.config.x.application_mode.beta ? false : true

Plendit::Application.config.x.signup.bedriftskunde_signup_link = 'http://goo.gl/forms/HkNI7f85XO'
