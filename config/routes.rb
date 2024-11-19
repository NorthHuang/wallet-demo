require 'sidekiq/web'
Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  mount Sidekiq::Web => '/sidekiq'

  resources :users, only: [] do
    collection do
      post :register
      post :login
      get :me
    end
  end

  resources :wallets, only: [] do
    collection do
      get :user_balance
    end
  end

  resources :transfers, only: [:index, :create]

  resources :deposits, only: [:index, :create]

  resources :withdrawals, only: [:index, :create] do
    collection do
      post :confirm
    end
  end
end
