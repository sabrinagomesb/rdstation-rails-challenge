require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'

  resources :products

  resource :cart, only: %i[show create] do
    collection do
      patch  'add_item'
      delete ':product_id', to: 'carts#destroy_item'
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root to: redirect('/api-docs')
end
