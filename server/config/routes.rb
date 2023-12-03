Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "up" => "rails/health#show", as: :rails_health_check

  resources :users
  resources :games
  resources :versions
  resources :saves
  put 'saves/:user_id/:version_id', to: 'saves#upload'
  get 'saves/latest/:user_id/:game_id', to: 'saves#latest'

  root to: redirect("/admin")
end
