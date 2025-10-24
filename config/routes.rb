Rails.application.routes.draw do
  # Rotas da API
  namespace :api do
    resources :documents, only: [:create, :index, :show]
  end

  # Rota de saúde
  get "up" => "rails/health#show", as: :rails_health_check
end
