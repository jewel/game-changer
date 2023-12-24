Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get "up" => "rails/health#show", as: :rails_health_check

  resources :bucket_files
  resources :users
  resources :games
  resources :versions
  resources :saves do
    collection do
      get :latest
    end
  end

  get 'install', to: 'clients#install'
  get 'clients/tarball', to: 'clients#tarball'

  root to: redirect("/admin")
end
