Rails.application.routes.draw do
  devise_for :users
  devise_for :admins
  devise_for :traders
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  get "pages/index"
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

 # ROOT PATH
  root "auth#index"
  get 'login/trader', to: 'auth#trader_login', as: 'login_trader'
  get 'login/admin', to: 'auth#admin_login', as: 'login_admin'
  post 'login/trader', to: 'auth#trader_authenticate'
  post 'login/admin', to: 'auth#admin_authenticate'
  get 'signup/trader', to: 'auth#trader_signup', as: 'signup_trader'
  post 'signup/trader', to: 'auth#create_trader_account'

  # mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  namespace :admin_panel do
    get '/', to: 'dashboard#index', as: :admn_dashboard 
    resources :users
  end

  resources :traders, only: [] do
    member do
      get :dashboard
      get :portfolio
      get :transactions
      post :buy_stock
      post :sell_stock
      get :logout
    end
  end
end