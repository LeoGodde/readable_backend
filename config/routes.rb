Rails.application.routes.draw do
  namespace :api do
    resources :documents, only: [:create, :index, :show]
    resources :webpage_urls, only: [:create, :index, :show]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
