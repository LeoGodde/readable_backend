class Api::ArticlesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_article, only: %w[show destroy]

  def create
    article = Article.new(article_params.merge(html_content: "processing"))

    if article.save
      render json: {
        message: "URL salva com sucesso!",
        article: article
      }, status: :created
    else
      render json: {
        errors: article.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def index
    articles = Article.all.order(created_at: :asc)
    render json: articles
  end

  def show
    render json: @article
  end

  def destroy
    if @article.destroy
      render json: { message: "Article deletada com sucesso!" }, status: :ok
    else
      render json: { error: "Erro ao deletar Article" }, status: :unprocessable_entity
    end
  end

  private

  def article_params
    params.require(:article).permit(:username, :url, :title)
  end

  def set_article
    @article = Article.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Article não encontrada" }, status: :not_found
  end
end
