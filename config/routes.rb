Rails.application.routes.draw do

  namespace :merchant do
    resources :dashboard, only: [:index] do
      get :fee_structure, on: :collection
      get :api_key, on: :collection
    end
    resources :sale, only: [:index, :create]
    resources :transactions, only: [:index]
    resources :reserve_schedules, only: [:index]
    resources :accounts, only: [:show] do
      member do 
        get :account_transactions
      end
    end
    resources :withdraws
  end
  namespace :admin do
    resources :dashboard, only: [:index]
    resources :merchants, only: [:index, :edit, :update]
    resources :payment_gateways
    resources :wallets
    resources :withdraws
    resources :fees
  end
  root to: 'visitors#index'
  devise_for :users, :controllers => { registrations: 'users/registrations', sessions: 'users/sessions'}
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get "about", to: "visitors#about"
  get "pricing", to: "visitors#pricing"
  get "faq", to: "visitors#faq"
  get "terms", to: "visitors#terms"
  get "privacy", to: "visitors#privacy"
  get "contact", to: "visitors#contact"
end
