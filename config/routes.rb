Rails.application.routes.draw do
  devise_for :vendors
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  devise_for :admins, controllers: { sessions: 'admins/sessions' }
  
  namespace :admin do
    resources :dashboard, only: [:index]
    resources :analytics, only: [:index]
    resources :customers, only: [:index, :show]
    resources :vendors, only: [:index, :show]
    resources :bookings, only: [:index, :show]
    resources :cars, only: [:index, :show]
    resources :documents, only: [:show] do
      member do
        patch :approve
        post :reject
      end
    end
  end


  resources :documents, only: [:create]
  resources :cars
  resources :bookings, only: [:new, :create]
  resources :payments, only: [:create, :show]

  resource :user, only: [] do
    patch :update_nationality
  end


  get 'user/home', to: 'users#home', as: :user_home
  get 'user/profile', to: 'users#profile', as: :user_profile
  get 'user/bookings', to: 'users#bookings', as: :user_bookings

  root "car_rental#index"
end
