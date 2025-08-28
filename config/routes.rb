# routes.rb
Rails.application.routes.draw do
  get 'sessions/new'
  root "contents#index"

  resources :contents, only: [:new, :create, :index, :show, :edit, :update, :destroy] do
    resource :favorite, only: [:create, :destroy]
    member do
      get :share
    end
    collection do
      post :preview_summary
    end
  end

  resources :comments

  resources :users, only: [:new, :create, :show, :edit, :update, :destroy] do
    member do
      delete :remove_avatar
    end
    collection do
      get :check_email
      get   :signup_sent
      get   :edit_password
      patch :update_password
      get  :finish_sign_up
    end
  end

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy', as: :logout
  get "/signup_sent", to: "users#signup_sent", as: :signup_sent
  get  "/users/finish_sign_up", to: "users#finish_sign_up"
  get '/users/check_email', to: 'users#check_email'

  match "*path",
    to: "application#render_404",
    via: :all,
    constraints: ->(req){ !req.path.start_with?("/rails") }
end
