Rails.application.routes.draw do
  root to: "visitors#index"

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  resources :events
  resources :payments
  resource :shopping_cart
end
