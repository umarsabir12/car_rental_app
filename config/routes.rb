Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  devise_for :admin_users, controllers: { sessions: 'admin_users/sessions' }
  
  get 'dashboard', to: 'admin#dashboard'
  namespace :admin do
    resources :customers, only: [:index]
    resources :vendors, only: [:index]
    resources :bookings, only: [:index]
    resources :cars, only: [:index, :show]
  end
  
  resources :cars
  resources :bookings, only: [:new, :create]
  resources :payments, only: [:create, :show]

  get 'user/home', to: 'users#home', as: :user_home
  get 'user/profile', to: 'users#profile', as: :user_profile
  get 'user/bookings', to: 'users#bookings', as: :user_bookings

  root "car_rental#index"
end
