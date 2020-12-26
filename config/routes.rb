Rails.application.routes.draw do
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
