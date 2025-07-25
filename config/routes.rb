Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  devise_for :vendors, controllers: { sessions: 'vendors/sessions', registrations: 'vendors/registrations' }
  devise_for :users, controllers: {sessions: 'users/sessions',registrations: 'users/registrations'}
  devise_for :admins, controllers: { sessions: 'admins/sessions' }
  
  namespace :admin do
    resources :dashboard, only: [:index]
    resources :analytics, only: [:index]
    resources :customers do
      collection do
        get :download_report
      end
    end
    resources :vendors do
      collection do
        get :download_report
      end
    end
    resources :invited_vendors, only: [:index, :new, :create]
    resources :bookings do
      collection do
        get :download_report
      end
    end
    resources :cars do
      collection do
        get :download_report
      end
    end
    resources :documents, only: [:show] do
      member do
        patch :approve
        post :reject
      end
    end
  end

  namespace :vendors do
    get 'dashboard', to: 'dashboard#index'
    resources :cars
    resources :bookings
    resources :documents
    resource :profile, only: [:show, :edit, :update]
    resources :payments, only: [:index, :show]
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
