require 'sidekiq/web'

MetadataCensus::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.

  id_regex = /[0-z\.\-]+/

  constraints({ id: id_regex, repository_id: id_regex }) do

    resource :repositories do
      get 'leaderboard'
      get 'map'
    end

    resources :repositories do

      resource :metadata, only: [] do

        member do
         get 'normalize'
         get 'search'
        end

      end
    end

  end

  # /admin
  namespace :admin do

    get 'scheduler'  # redirected to resourcful path

    constraints({ repository_id: id_regex }) do
      resources :repositories do

        resources :snapshots

        get 'scheduler'
        get 'status'

        resources :metrics, only: [] do
          get  'last_updated'
          post 'schedule'
        end

      end
    end

  end

  root :to => 'static_pages#home'

  get '/metrics', to: 'metrics#overview'
  get '/metrics/status', to: 'metrics#status'

  mount Sidekiq::Web, at: '/sidekiq'

end
