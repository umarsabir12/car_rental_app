Rails.application.routes.draw do
  resources :companies, only: [:index]
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  devise_for :vendors, controllers: { 
    sessions: 'vendors/sessions', 
    registrations: 'vendors/registrations',
    passwords: 'vendors/passwords'
  }

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }
  
  devise_for :admins, controllers: { sessions: 'admins/sessions' }
  
  # Admin profile routes (outside namespace for simpler URLs)
  resource :admins, only: [:show, :edit, :update, :index], path: 'admin'
  
  # Manual OmniAuth routes for Users - accept both GET and POST
  match '/users/auth/google_oauth2', 
    to: 'users/omniauth_callbacks#passthru', 
    as: :user_google_oauth2_omniauth_authorize,
    via: [:get, :post]
  
  # Manual OmniAuth routes for Vendors - accept both GET and POST
  match '/vendors/auth/google_oauth2', 
    to: 'vendors/omniauth_callbacks#passthru', 
    as: :vendor_google_oauth2_omniauth_authorize,
    via: [:get, :post]
  
  # Callback route
  get '/auth/google_oauth2/callback', to: 'omniauth_callbacks#google_oauth2'

  namespace :users do
    get 'documents', to: 'documents#index'
    get 'bookings', to: 'bookings#index'
    patch 'bookings/:id/cancel', to: 'bookings#cancel', as: :cancel_booking
    get 'profile', to: 'profiles#index'
    resources :payments, only: [:show] do
      member do
        get :success
        get :cancel
        post :create_checkout
      end
    end
  end
  resources :users, only: [:show, :edit, :update]

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :analytics, only: [:index]
    resources :email_test, only: [:index] do
      collection do
        post :send_test
      end
    end
    resources :activities, only: [:index, :show] do
      collection do
        get :export
      end
    end
    resources :customers do
      collection do
        get :download_report
      end
    end
    resources :vendors do
      collection do
        get :download_report
      end
      member do
        delete :destroy
        patch :restore
        post :invoice
      end
      # Nested invoices routes - admin can create invoices for vendors
      resources :invoices, only: [:index, :new, :create]
    end
    
    # Standalone invoices routes - admin can manage all invoices
    resources :invoices, only: [:show, :edit, :update, :destroy] do
      member do
        patch :mark_as_paid
      end
    end
    
    resources :invited_vendors, only: [:index, :new, :create]
    resources :vendor_requests, only: [:index] do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :bookings do
      collection do
        get :download_report
      end
      member do
        patch :update
      end
    end
    resources :cars do
      collection do
        get :download_report
      end
    end
    resources :transactions, only: [:index, :show] do
      member do
        patch :refund
      end
    end
    resources :settings, only: [:index, :update] do
      collection do
        post :test_webhook
        post :clear_cache
        get :system_info
      end
    end
    resources :documents, only: [:show] do
      member do
        patch :approve
        post :reject
      end
    end
    resources :car_documents, only: [:show] do
      member do
        patch :approve
        post :reject
      end
    end
    resources :features, except: [:show, :new]
  end

  namespace :vendors do
    get 'dashboard', to: 'dashboard#index'
    get 'companies', to: 'companies#index', as: :companies
    
    # Cars routes to use slug
    get 'cars', to: 'cars#index', as: :cars_index
    get 'cars/new', to: 'cars#new', as: :new_car
    post 'cars', to: 'cars#create'
    get 'car/:id', to: 'cars#show', as: :car  # Singular for show
    get 'car/:id/edit', to: 'cars#edit', as: :edit_car  # Singular for edit
    patch 'car/:id', to: 'cars#update'
    put 'car/:id', to: 'cars#update'
    delete 'car/:id', to: 'cars#destroy'
    delete 'cars/:id/remove_image', to: 'cars#remove_image', as: :remove_image_car

    resources :bookings
    resources :documents
    resources :payments, only: [:index, :show]
    # Vendors can only VIEW their invoices (read-only)
    resources :invoices, only: [:index, :show] do
      member do
        post :pay
      end
    end
  end

  # Vendor profile routes (outside namespace for simpler URLs)
  resource :vendor, only: [:show, :edit, :update]

  resources :documents, only: [:create]
  
  # UPDATED: Public cars routes with clean filter URLs
  get 'cars', to: 'cars#index', as: :cars
  get 'filter_options', to: 'cars#filter_options', as: :filter_options
  get 'cars/:category', to: 'cars#index', as: :cars_by_category
  get 'cars/:category/:brand', to: 'cars#index', as: :cars_by_category_brand
  get 'cars/:category/:brand/:model', to: 'cars#index', as: :cars_by_all_filters
  get 'car/:id', to: 'cars#show', as: :car
  
  resources :bookings, only: [:new, :create]

  get 'list-your-car-rental-marketplace', to: 'vendor_requests#new', as: :new_vendor_request
  post 'list-your-car-rental-marketplace', to: 'vendor_requests#create', as: :vendor_requests
  # resource :user, only: [:show, :edit, :update] do
  #   patch :update_nationality
  # end

  # Stripe webhook
  post 'webhooks/stripe', to: 'webhooks#stripe'

  get 'user/home', to: 'users#home', as: :user_home

  root "car_rental#index"
  get '/terms_of_use', to: 'car_rental#terms'

  resources :blogs, only: [:index, :show], param: :slug
end