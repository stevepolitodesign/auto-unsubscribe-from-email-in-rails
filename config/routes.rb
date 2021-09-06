Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'static#home'

  devise_for :users

  resources :mailer_subscription_unsubcribes, only: [:show, :update]
  resources :mailer_subscriptions, only: [:index, :create, :update]
end