require 'sidekiq/web'

MetadataCensus::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  id_regex = /[0-z\.\-]+/

  get 'repository/:repository', to: 'repositories#show', 
    constraints: { repository: id_regex }

  get 'repository/:repository/metric/:metric', to: 'metrics#show',
    constraints: { repository: id_regex }

  get 'repositories', to: 'repositories#index'

  get 'repository/:repository/score', to: 'repositories#score',
    constraints: { repository: id_regex }

  get 'repository/:repository/scores', to: 'repositories#scores',
    constraints: { repository: id_regex }

  get 'repository/:repository/metadata', to: 'metadata#search',
    constraints: { repository: id_regex }

  post 'repository/:repository/metric/:metric/compute', to: 'metrics#compute',
    constraints: { repository: id_regex }

  # /admin
  namespace :admin do

    get 'scheduler'  # redirected to resourcful path

    constraints({ repository_id: id_regex }) do
      resources :repositories do

        resource :metadata

        get 'scheduler'
        get 'status'

        resources :metrics, only: [] do
          get  'last_updated'
          post 'schedule'
        end

      end
    end

  end
  
  get 'metadata/search'

  get 'repositories/leaderboard'

  root :to => 'static_pages#home'

  get '/metrics', to: 'metrics#overview'
  get '/metrics/status', to: 'metrics#status'

  get '/repositories/map', to: 'repositories#map'
  get '/metadata', to: 'metadata#select'

  mount Sidekiq::Web, at: '/sidekiq'

end
