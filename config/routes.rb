Rails.application.routes.draw do
  get "sessions/logout"
  get "sessions/omniauth"
  get "users/show"
  # get "welcome/index"
  # # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  #
  # # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check
  #
  # # Render dynamic PWA files from app/views/pwa/*
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  #
  # # Defines the root path route ("/")
  # # root "posts#index"
  root "welcome#index"
  get "welcome/index", to: "welcome#index", as: "welcome"

  get "/logout", to: "sessions#logout", as: "logout"
  get "/auth/google_oauth2/callback", to: "sessions#omniauth"
  get "/auth/failure", to: "sessions#failure", as: "failure"
  get "users/manage", to: "users#manage", as: "manage_users"
  patch "users/update_admin_status", to: "users#update_admin_status", as: "update_admin_status"
  delete "users/:id", to: "users#destroy", as: "delete_user"

  resources :run_time_objects do
    resources :images do
      member do
        get :download
      end
    end
  end

  resources :run_time_objects do
    resources :images do
      post "rescan", on: :member
    end
  end

  resources :run_time_objects do
    member do
      get :share
      post :share_with_users
    end
  end
end
