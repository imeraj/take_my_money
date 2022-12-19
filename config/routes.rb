Rails.application.routes.draw do
  root to: "visitors#index"

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  devise_scope :user do
    post "users/sessions/verify" => "Users::SessionsController"
    get "users/sessions/two_factor" => "Users::SessionsController"
  end

  resources :events
  resources :payments
  resource :shopping_cart

  get "paypal/approved", to: "paypal_payments#approved"
  get "paypal/rejected", to: "paypal_payments#rejected"
end
