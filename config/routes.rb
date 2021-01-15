Rails.application.routes.draw do
  
  resources :withdraws
  namespace :admin do
    resources :dashboard, only: [:index]
    resources :merchants, only: [:index, :edit, :update]
    resources :payment_gateways
    resources :wallets
    resources :withdraws
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
