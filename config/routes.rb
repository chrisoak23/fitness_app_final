Rails.application.routes.draw do
  get 'animes/index'
  resources :animes do
    collection do
      get :search
      post :import_from_api
    end
  end
  get 'animes/show'
  get 'animes/search'
  get '/animes/populate', to: 'animes#populate_with_top_anime'
  resources :rankings, only: [:index, :new, :create, :edit, :update, :destroy]
  root 'pages#home'
  get 'about', to: 'pages#about'
  resources :goals
  get 'signup', to: 'users#new'
  resources :users, except: [:new]
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  resources :trainers, except: [:destroy]
end
