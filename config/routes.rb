Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  devise_for :vendors, controllers: { sessions: 'vendors/sessions', registrations: 'vendors/registrations' }
  devise_for :users, controllers: {sessions: 'users/sessions',registrations: 'users/registrations'}
  devise_for :admins, controllers: { sessions: 'admins/sessions' }
  
  namespace :users do
    get 'documents', to: 'documents#index'
    get 'bookings', to: 'bookings#index'
    get 'profile', to: 'profiles#index'
    resources :payments, only: [:show] do
      member do
        get :success
        get :cancel
        post :create_checkout
      end
    end
  end

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
    resources :cars do
      member do
        delete :remove_image
      end
    end
    resources :bookings
    resources :documents
    resources :payments, only: [:index, :show]
  end

  # Vendor profile routes (outside namespace for simpler URLs)
  resource :vendor, only: [:show, :edit, :update]

  resources :documents, only: [:create]
  resources :cars
  resources :bookings, only: [:new, :create]

  resource :user, only: [] do
    patch :update_nationality
  end

  # Stripe webhook
  post 'webhooks/stripe', to: 'webhooks#stripe'

  get 'user/home', to: 'users#home', as: :user_home

  root "car_rental#index"
end
