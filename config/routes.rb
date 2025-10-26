Rails.application.routes.draw do
  # Root landing page
  root "static#home"

  # Auth
  devise_for :users

  # Companies → Jobs (shallow), with JobApplications under Jobs
  resources :companies, param: :id, shallow: true do
    resources :jobs, param: :id do
      resources :job_applications, only: [ :index, :create, :destroy ]
    end
  end

  get "job-listings", to: "jobs#listings", as: :job_listings
  get "company-listings", to: "companies#listings", as: :company_listings

  # Top-level Jobs index (list across companies; admin sees all)
  resources :jobs, only: [ :index ], param: :id

  # Current user's profile management
  resource :profile, only: [ :show, :new, :create, :edit, :update ] do
    resources :experiences, except: [ :show ]
  end

  # Public profiles (SEO)
  get "/p/:id", to: "public_profiles#show", as: :public_profile

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest"        => "rails/pwa#manifest",       as: :pwa_manifest
end
