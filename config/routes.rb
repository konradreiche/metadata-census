require 'sidekiq/web'

MetadataCensus::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.
  
  get 'snapshots', to: 'static_pages#snapshots'
  get 'metrics', to: 'static_pages#metrics'

 id_regex = /[0-z\.\-]+/

  constraints({ id: id_regex, repository_id: id_regex }) do

    resource :repositories, only: [] do
      post 'weighting'
    end

    resources :repositories, only: [:show, :index] do

      resources :snapshots, only: [:show] do

        member do 
          get 'distribution'
          get 'statistics'
          get 'metadata'
        end

        resources :metrics, only: [:show]
        resource :metadata, only: [] do

          member do
            get 'normalize'
            get 'search'
          end
        end
      end
    end
  end

  resources :session, only: [:new, :create, :destroy]

  # /admin
  namespace :admin do

    get 'scheduler'  # redirected to resourcful path

    constraints({ repository_id: id_regex }) do

      resource :repositories, only: [] do
        post 'compile'
      end

      resources :repositories, only: [:create, :new, :index] do

        resources :snapshots, only: [:new, :create] do
          get 'scheduler'
          get 'status'

            resources :metrics, only: [] do
              get  'last_updated'
              post 'schedule'
            end

        end

      end
    end

  end

  root :to => 'static_pages#home'

  get '/metrics', to: 'metrics#overview'
  get '/metrics/status', to: 'metrics#status'

  mount Sidekiq::Web, at: '/sidekiq'

end
