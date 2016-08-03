Rails.application.routes.draw do
  devise_for :users
  resources :users
  resources :games do
    member do
      patch :join
      patch :forfeit
      get :status
      patch :offer_draw
      patch :accept_draw
      patch :rescind_draw
      patch :decline_draw
    end
    resources :pieces, only: [:update] do
      member do
        patch :promote
        patch :move
      end
    end
  end
  get '/games/:id/getPieces', to: 'games#getPieces', as: 'get_pieces'
  get '/games/:id/getActivePlayer', to: 'games#getActivePlayer', as: 'get_active_player'
  get '/open' => 'games#open', :as => :open
  get '/games/:id/get_firebase_info', to: 'games#firebase_info', as: 'firebase_info'
  root 'games#index'
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
