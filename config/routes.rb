Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  get 'admin/switch_user' => 'switch_user#set_current_user'
  get 'switch_user',               to: redirect('/')
  get 'switch_user/remember_user', to: redirect('/')

  resources :locations, path: '/users/locations'
  resources :bookings, path: '/users/bookings' do
    resources :messages
    member do
      get 'show_price'
      post 'decline'
      post 'accept'
      post 'cancel'
    end
  end

  #get 'verify_sms', path: '/users/verify_sms', as: :verify_sms, to: 'users#verify_sms'
  get 'user',  to: 'users#index'
#  get 'users', to: redirect('/user'), as: 'not_users'
  get 'users/edit', to: 'users#edit', as: 'users_edit'

  devise_for :users, :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks",
    :registrations      => "users/registrations",
    :sessions           => "users/sessions"
  }, path_names: { sign_in: 'login', sign_out: 'logout', registration: 'register' }


  resource :users, only: [:index, :update] do
    #resources :favorite_lists do
    #  resources :favorite_ads
    #end
    member do
      post 'ads/create'
      get 'ads', to: 'ads#list'
      #get 'verify_email'
      get  'verify_sms'
      post 'verify_sms', to: 'users#do_verify_sms'
      post 'mark_all_notifications_noticed', to: 'users#mark_all_notifications_noticed'
    end

    # maybe these should be in the "namespace" users ?
    resources :favorite_ads, only: [:index, :create, :destroy]
    resources :ads do
      resources :ad_images, only: [:index, :create, :update, :destroy]
    end
  end
  resources :users, only: [:index, :show]


  resources :favorite_ads




  get 'misc/postal_place'
  get 'misc/wip'

  get '/search', to: 'ads#search'

  get '/new', to: 'ads#new', as: 'new_ad'



  resources :feedbacks
  resources :ads do
    member do
      get 'preview'
      get 'gallery'
      get 'double_calendar'
      get 'single_calendar'
      get 'image_manager'
      post 'pause'
      post 'stop'
      post 'approve'
      post 'suspend'
      post 'resume'
      post 'submit_for_review'
    end
    resources :bookings
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
