class Api::WebpageUrlsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    webpage_url = WebpageUrl.new(webpage_url_params)

    if webpage_url.save
      render json: {
        message: "URL salva com sucesso!",
        webpage_url: webpage_url
      }, status: :created
    else
      render json: {
        errors: webpage_url.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def index
    webpage_urls = WebpageUrl.all
    render json: webpage_urls
  end

  def show
    webpage_url = WebpageUrl.find(params[:id])
    render json: webpage_url
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Webpage URL não encontrada" }, status: :not_found
  end

  private

  def webpage_url_params
    params.require(:webpage_url).permit(:username, :url, :title)
  end
end
