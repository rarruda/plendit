Rails.application.routes.draw do
  devise_for :users
  #devise_for :users, controllers: {
  #  sessions: 'sessions'
  #}


  get 'misc/frontpage'

  get 'misc/create_1'

  get 'misc/create_2'

  get 'misc/create_3'

  get 'misc/result'

  get 'misc/faq'

  get 'misc/about'

  get 'misc/ad'

  get 'misc/personal_requests'

  get '/search', to: 'ads#search'

  get '/ads/:id', to: 'ads#view', as: 'ad'

  #get '/admin' to: 'misc#admin'

  scope '/admin' do
    resources :messages
    resources :booking_statuses
    resources :bookings
    resources :user_statuses
    resources :ad_items
    resources :feedbacks
    resources :ads
    resources :users
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
