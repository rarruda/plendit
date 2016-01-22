Rails.application.routes.draw do

  scope '/internal-backstage' do
    mount OkComputer::Engine, at: 'health-check', as: 'ok_computer'
    mount ResqueWeb::Engine,  at: 'resque-web'

    #https://github.com/resque/resque-web/pull/79
    #https://github.com/resque/resque-web/issues/76
    ResqueWeb::Engine.eager_load!

    ActiveAdmin.routes(self)
    get   'admin/switch_user' => 'switch_user#set_current_user'
    get   'switch_user',               to: redirect('/')
    get   'switch_user/remember_user', to: redirect('/')
    get   '/',                         to: 'backstage#index', as: 'backstage'
    get   'broadcast',                 to: 'backstage#broadcast'
    post  'broadcast',                 to: 'backstage#broadcast'
    get   'frontpage_ads',             to: 'backstage#frontpage_ads'
    post  'frontpage_ads',             to: 'backstage#frontpage_ads'
    post  'save_frontpage_ads',        to: 'backstage#save_frontpage_ads'
    get   'boat_admin',                to: 'backstage#boat_admin'
    get   'pending_ad_reviews',        to: 'backstage#pending_ad_reviews'
    get   'pending_kyc_reviews',       to: 'backstage#pending_kyc_reviews'
    get   'kyc_document/:guid',        to: 'backstage#kyc_document', as: 'kyc_document'
    patch 'kyc_document/:guid',        to: 'backstage#kyc_document'
    get   'kyc_image/:guid',           to: 'backstage#kyc_image', as: 'kyc_image'
  end

  resources :locations, path: '/me/locations', param: :guid, only: [:index, :new, :create, :edit, :update, :destroy] do
    member do
      post 'make_favorite'
    end
  end

  resources :bookings, path: '/me/bookings', param: :guid, only: [:index, :show, :new, :create, :update] do
    resources :messages
    resources :accident_reports, only: [:index, :create]
    member do
      get  'booking_calc'
      get  'show_price'
      post 'accept'
      post 'decline'
      post 'abort'
      post 'cancel'
    end
  end

  resources :user_payment_cards, path: '/me/cards', param: :guid, only: [:index, :new, :create, :destroy] do
    member do
      post 'make_favorite'
    end
  end
  # move to /me/payment/cards

  # see: https://github.com/plataformatec/devise/blob/master/lib/devise/rails/routes.rb
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations:      'users/registrations',
    sessions:           'users/sessions'
  }, path: '/me', path_names: {
    sign_in:      'login',
    sign_out:     'logout',
    registration: 'register'
    #password: 'secret',
    #confirmation: 'verification',
    #edit: 'edit/profile'
  }

  resource :users, path: '/me', only: [:edit, :update] do
    #resources :favorite_lists do
    #  resources :favorite_ads
    #end
    member do
      get   '/',                       to: 'users#private_profile' #'users#index'
      post  'ads/create'
      get   'ads',                     to: 'ads#list'
      get   'private_profile',         controller: 'users'
      get   'rental_history'

      get   'booking_calc',            controller: 'bookings'

      get   'payment'
      match 'payment/payout',          to: 'users#payout',                 via: [:get, :post]
      match 'bank_account',            via: [:get, :post]

      match 'verify/drivers_license',  to: 'users#verify_drivers_license', via: [:get, :post]
      match 'verify/id_card',          to: 'users#verify_id_card',         via: [:get, :post]
      match 'verify/boat_license',     to: 'users#verify_boat_license',    via: [:get, :post]
      match 'verify/mobile',           to: 'users#verify_mobile',          via: [:get, :post]
      match 'verify/email',            to: 'users#verify_email',           via: [:get, :post]

      match 'finish_signup',           controller: 'users', via: [:get, :patch]

      post 'verify_sms'
      post 'resend_verification_sms'
      post 'mark_all_notifications_noticed', controller: 'users'
      delete 'identity', to: 'users#destroy_identity'
    end

    # maybe these should be in the "namespace" users ?
    resources :favorite_ads, only: [:index, :create, :destroy], path: 'favorites'
    resources :ads do
      member do
        post 'new_location'
        post 'existing_location'
      end

      resources :ad_images, only: [:index, :create, :update, :destroy]
    end
    resources :feedbacks
  end

  get 'user/:id', to: 'users#show', as: 'user'


  get 'about-us', to: 'misc#about'
  get 'contact',  to: 'misc#contact'
  get 'privacy',  to: 'misc#privacy'
  get 'terms',    to: 'misc#terms' #feel free to find a better name for terms and conditions


  scope '/resources' do
    get 'postal_place', to: 'misc#postal_place'
    get 'mangopay/callback'
  end


  get '/search', to: 'ads#search'
  get '/new',    to: 'ads#new', as: 'new_ad'


  resources :ads, path: '/listing' do
    member do
      get 'preview'
      get 'gallery'
      get 'unavailability'
      get 'nested_images'
      post 'listing_image',      to: 'ads#ad_image'
      get 'edit_availability'

      post 'pause'
      post 'stop'
      post 'approve'
      post 'suspend'
      post 'refuse'
      post 'resume'
      post 'submit_for_review'
      post 'unpublish_and_edit'
    end

    resources :payin_rules, param: :guid, only: [:index, :create, :destroy] do
      collection do
        post 'payout_estimate'
      end
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # So lograge logs 404's: (in production)
  get '*unmatched_route', to: 'application#route_not_found' if Rails.env.production?

  # You can have the root of your site routed with "root"
  root 'misc#frontpage'

end
