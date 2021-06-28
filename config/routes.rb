# frozen_string_literal: true

Rails.application.routes.draw do

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :api do
    namespace :v1 do
      resources :sales, only: [:virtual_terminal] do
        collection do
          post 'virtual_terminal'
        end
      end
      resources :auth_token, only: [:token] do
        collection do
          post 'token'
        end
      end
    end
  end

  namespace :merchant do
    resources :banks
    resources :dashboard, only: [:index] do
      get :fee_structure, on: :collection
      get :api_key, on: :collection
    end
    resources :sale, only: %i[index create] do
      get :refund, on: :collection
    end
    resources :dashboard, only: %i[index edit update show] do
      get :fee_structure, on: :collection
      get :api_key, on: :collection
    end
    resources :sale, only: %i[index create]
    resources :transactions, only: [:index] do
      get :transaction_detail, on: :collection
    end
    resources :reserve_schedules, only: [:index]
    resources :accounts, only: [:show] do
      member do
        get :account_transactions
      end
    end
    resources :withdraws
    resources :account_transfers do
      get :check_email, on: :collection
    end
    resources :verification, only: [:index] do
      get :company_info, on: :collection
      get :contact_details, on: :collection
      get :brand_info, on: :collection
      get :bank_details, on: :collection
      get :verify_bank, on: :collection
      get :verification_status, on: :collection
      get :thankyou, on: :collection
      post :save_company_detail, on: :collection
      post :save_brand_info, on: :collection
      post :save_bank_details, on: :collection
      post :save_contact_details, on: :collection
      post :complete_verification, on: :collection
    end
    resources :rewards, only: %i[index]
  end
  namespace :admin do
    resources :dashboard, only: [:index] do
        get :verify, on: :collection
    end
    resources :merchants, only: %i[index edit update]
    resources :payment_gateways
    resources :wallets
    resources :withdraws do
      post :accept, on: :member
    end
    resources :fees
  end
  root to: 'visitors#index'
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'about', to: 'visitors#about'
  get 'search', to: 'visitors#search'
  get 'marketplace', to: 'visitors#marketplace'
  get 'pricing', to: 'visitors#pricing'
  get 'faq', to: 'visitors#faq'
  get 'terms', to: 'visitors#terms'
  get 'privacy', to: 'visitors#privacy'
  get 'contact', to: 'visitors#contact'
  get 'docs', to: 'visitors#docs'

end
