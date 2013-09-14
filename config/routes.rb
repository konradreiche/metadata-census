require 'sidekiq/web'

MetadataCensus::Application.routes.draw do

  id = { repository: /[0-z\.]+/ }

  get 'repository/:repository', to: 'repositories#show', 
    constraints: id

  get 'repository/:repository/metric/:metric', to: 'metrics#show',
    constraints: id

  get 'repositories', to: 'repositories#index'

  get 'repository/:repository/score', to: 'repositories#score',
    constraints: id

  get 'repository/:repository/scores', to: 'repositories#scores',
    constraints: id

  get 'repository/:repository/metadata', to: 'metadata#search',
    constraints: id

  post 'repository/:repository/metric/:metric/compute', to: 'metrics#compute',
    constraints: id

  get 'report/metric'

  get 'admin/control'

  namespace :admin do
    resources :repositories do
      resource :metadata
    end
    get 'importer'
    post 'import'
  end
  
  get 'metadata/search'

  get 'repositories/leaderboard'

  root :to => 'static_pages#home'

  get '/metrics', to: 'metrics#overview'
  get '/metrics/status', to: 'metrics#status'

  get '/repositories/map', to: 'repositories#map'
  get '/metadata', to: 'metadata#select'

  mount Sidekiq::Web, at: '/sidekiq'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
