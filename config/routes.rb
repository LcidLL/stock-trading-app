Rails.application.routes.draw do
  devise_for :admins
  devise_for :traders
  get "pages/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)


  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")

  root "login#new"
  post 'login', to: 'login#create'

  namespace :admin do
    resources :users
  end

  resources :traders, only: [] do
    member do
      get :dashboard
      get :portfolio
      get :transactions
      post :buy_stock
      post :sell_stock
    end
  end
end
