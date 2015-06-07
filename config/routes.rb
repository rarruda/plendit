Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :locations, path: '/users/locations'
  resources :bookings, path: '/users/bookings' do
    resources :messages
  end

  #get 'verify_sms', path: '/users/verify_sms', as: :verify_sms, to: 'users#verify_sms'
  get 'user',  to: 'users#index'
  get 'users', to: 'users#index'
  get 'users/ads', to: 'ads#list'
  get 'users/edit', to: 'users#edit', as: 'users_edit'
  devise_for :users, :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks"
    #sessions: 'sessions'
  }
  resource :users do
    resources :ads
    #resources :favorite_lists do
    #  resources :favorite_ads
    #end
    member do
      get 'verify_sms'
    end
  end
  get 'users/:id', to: 'users#show'

  #resources :favorite_lists do #, path: '/users/favorite_lists'
  #  resources :favorite_ads
  #end
  resources :favorite_ads


  get 'ads/create_3'

  get 'misc/wip'

  get '/search', to: 'ads#search'


  #resources :bookings
  resources :feedbacks
  resources :ads do
    resources :ad_images, only: [:index, :create, :update, :destroy]
    member do
      get 'preview'
    end
  end
  # fixme: should be retired in the future:
  resources :ad_images




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
