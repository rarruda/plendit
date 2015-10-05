Rails.application.routes.draw do

  scope '/internal-backstage' do
    mount OkComputer::Engine, at: "health-check"
    ActiveAdmin.routes(self)
    get 'admin/switch_user' => 'switch_user#set_current_user'
    get 'switch_user',               to: redirect('/')
    get 'switch_user/remember_user', to: redirect('/')
  end


  resources :locations, path: '/me/locations', only: [:index, :new, :create, :edit, :update, :destroy] do
    member do
      post 'make_favorite'
    end
  end

  resources :bookings, path: '/me/bookings', param: :guid do
    resources :messages
    member do
      get 'show_price'
      post 'decline'
      post 'accept'
      post 'cancel'
    end
  end

  get '/me/cards/flush_cache', as: 'cards_flush_cache', to: 'user_payment_cards#flush_cache'
  resources :user_payment_cards, path: '/me/cards', param: :guid, only: [:index, :new, :create, :destroy, :flush_cache]


  # see: https://github.com/plataformatec/devise/blob/master/lib/devise/rails/routes.rb
  devise_for :users, :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks",
    :registrations      => "users/registrations",
    :sessions           => "users/sessions"
  }, :path => '/me', path_names: {
    sign_in:  'login',
    sign_out: 'logout',
    registration: 'register'
    #password: 'secret',
    #confirmation: 'verification',
    #edit: 'edit/profile'
  }


  resource :users, path: '/me', only: [:index, :edit, :update] do
    #resources :favorite_lists do
    #  resources :favorite_ads
    #end
    member do
      get '/',  to: 'users#index'
      post 'ads/create'
      get 'ads', to: 'ads#list'

      #get 'verify_email'
      post 'verify_sms'
      post 'mark_all_notifications_noticed', to: 'users#mark_all_notifications_noticed'
    end

    # maybe these should be in the "namespace" users ?
    resources :favorite_ads, only: [:index, :create, :destroy], path: 'favorites'
    resources :ads do
      resources :ad_images, only: [:index, :create, :update, :destroy]
    end
    resources :feedbacks
  end

  get 'user/:id', to: 'users#show', as: 'user'


  get 'about-us', to: 'misc#about'
  get 'contact',  to: 'misc#contact'
  get 'privacy',  to: 'misc#privacy'
  get 'terms',    to: 'misc#terms' #feel free to find a better name for terms and conditions
  get 'help',     to: 'misc#help'
  get 'issues',   to: 'misc#issues'


  scope '/resources' do
    get 'postal_place', to: 'misc#postal_place'
    get 'mangopay/callback'
    get 'renter_price_estimate', to: 'misc#renter_price_estimate'
  end


  get '/search', to: 'ads#search'
  get '/new',    to: 'ads#new', as: 'new_ad'


  resources :ads, path: '/listing' do
    member do
      get 'preview'
      get 'gallery'
      get 'unavailability'
      get 'double_calendar'
      get 'single_calendar'
      get 'image_manager'
      get 'edit_availability'
      post 'pause'
      post 'stop'
      post 'approve'
      post 'suspend'
      post 'resume'
      post 'submit_for_review'
    end
  end

  # fixme: should be retired in the future:
  resources :ad_images do
    member do
      post 'make_primary'
    end
  end




  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'misc#frontpage'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
