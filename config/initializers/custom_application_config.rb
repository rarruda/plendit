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


Plendit::Application.config.x.customerservice.email          ='NOSPAM__kundesenter@plendit.no'

Plendit::Application.config.x.frontpage.popular_ads = [
  { title: 'Bil',
    term:  'bil',
    image: 'promo_imgs/bil.jpg'
  },
  { title: 'Bolig',
    term:  'bolig',
    image: "promo_imgs/bolig.jpg"
  },
  { title: 'Verktøy',
    term:  'verktøy',
    image: "promo_imgs/verktoy.jpg"
  },
  { title: 'Scooter',
    term:  'scooter',
    image: "promo_imgs/scooter.jpg"
  },
  { title: 'Sykkel',
    term:  'sykkel',
    image: "promo_imgs/sykkel.jpg"
  },
  { title: 'Telt',
    term:  'telt',
    image: "promo_imgs/telt.jpg"
  }
]

Plendit::Application.config.x.frontpage.hero_videos = [
  {
    still: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/baatliv_2_still.jpg',
    mp4: nil,
    webm: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/baatliv_2.webm'
  },
  {
    still: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/baatliv_5_still.jpg',
    mp4: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/baatliv_5.mp4',
    webm: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/baatliv_5.webm'
  },
  {
    still: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/baatliv_6_still.jpg',
    mp4: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/baatliv_6.mp4',
    webm: nil
  },
  {
    still: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/baatliv_7_still.jpg',
    mp4: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/baatliv_7.mp4',
    webm: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/baatliv_7.webm'
  },
  {
    still: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/baatliv_8_still.jpg',
    mp4: 'https://s3.eu-central-1.amazonaws.com/plendit-videos/baatliv_8.mp4',
    webm: nil
  },
]
