# http://guides.rubyonrails.org/configuring.html#custom-configuration

#Plendit::Application.config.x.payment_processing.schedule = :daily
#Plendit::Application.config.x.payment_processing.retries  = 3
#Plendit::Application.config.x.super_debugger = true
# read as:
#Rails.configuration.x.super_debugger

include ActionView::Helpers::NumberHelper

# "kr 50.000,-"
Plendit::Application.config.x.insurance.max_insurance_value  = number_to_currency( 50000, unit: 'kr ', delimiter: ".", separator: "," ).gsub(/\,00$/, ",-")
Plendit::Application.config.x.view.current_num_ads           = number_with_delimiter( 5000, delimiter: "." )

Plendit::Application.config.x.map.default_center_coordinates = { lat: 61.5, lon: 11.0 }
Plendit::Application.config.x.map.default_zoom_level         = 6
Plendit::Application.config.x.map.google_maps_js_api_key     ='AIzaSyAwciykMKFfGsTiDrqAwg80C5FCSq6vQr8'

Plendit::Application.config.x.customerservice.email          ='NOSPAM__kundesenter@plendit.no'
Plendit::Application.config.x.customerservice.website        ='https://plendit.freshdesk.com/support/home'

Plendit::Application.config.x.organization.phone_number      ='+47 97 04 43 99'
Plendit::Application.config.x.organization.org_id            ='915 252 230'

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
  { title: 'Bil',
    term:  'bil',
    image: 'promo_imgs/bil.jpg'
  },
  { title: 'Bolig',
    term:  'bolig',
    image: 'promo_imgs/bolig.jpg'
  },
  { title: 'Verktøy',
    term:  'verktøy',
    image: 'promo_imgs/verktoy.jpg'
  },
  { title: 'Scooter',
    term:  'scooter',
    image: 'promo_imgs/scooter.jpg'
  },
  { title: 'Sykkel',
    term:  'sykkel',
    image: 'promo_imgs/sykkel.jpg'
  },
  { title: 'Telt',
    term:  'telt',
    image: 'promo_imgs/telt.jpg'
  }
]

Plendit::Application.config.x.frontpage.hero_videos = [
  # båtliv
  {
    still: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/baatliv_3_still.jpg',
    mp4:   'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/baatliv_3.mp4',
    webm:  'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/baatliv_3.webm'
  },
  {
    still: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/baatliv_5_still.jpg',
    mp4:   'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/baatliv_5.mp4',
    webm:  'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/baatliv_5.webm'
  },
  {
    still: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/baatliv_6_still.jpg',
    mp4:   'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/baatliv_6.mp4',
    webm:  'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/baatliv_6.webm'
  },

  # hjem
  {
    still: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/hjem_1.jpg',
    mp4:   'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/hjem_1.mp4',
    webm:  'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/hjem_1.webm'
  },
  {
    still: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/hjem_2_still.jpg',
    mp4:   'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/hjem_2.mp4',
    webm:  'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/hjem_2.webm'
  },
  {
    still: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/hjem_7.jpg',
    mp4:   'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/hjem_7.mp4',
    webm:  'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/hjem_7.webm'
  },
  {
    still: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/hjem_8.jpg',
    mp4:   'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/hjem_8.mp4',
    webm:  'https://s3.eu-central-1.amazonaws.com/plendit-videos/frontpage-videos/hjem_8.webm'
  },
]

Plendit::Application.config.x.frontpage.explainer_video_url = 'https://www.youtube.com/embed/mqB032_uek4?rel=0'
