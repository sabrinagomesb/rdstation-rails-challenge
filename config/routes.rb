require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  resources :products

  resource :cart, only: %i[show create] do
    post 'add_item', on: :collection
    delete ':product_id', to: 'carts#destroy_item', on: :collection
  end

  get "up" => "rails/health#show", as: :rails_health_check
  root "rails/health#show"
end
