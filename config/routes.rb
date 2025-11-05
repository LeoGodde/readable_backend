Rails.application.routes.draw do
  namespace :api do
    resources :articles, only: [ :create, :index, :show, :destroy ]
    post "articles/:id/reprocess", to: "articles#reprocess", as: :reprocess_article
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
