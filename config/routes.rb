Rails.application.routes.draw do
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
