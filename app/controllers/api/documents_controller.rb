class Api::DocumentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    begin
      sanitized_html = HtmlSanitizerService.new(document_params[:html_content]).call
      document = Document.new(document_params.merge(html_content: sanitized_html))
    rescue NameError => e
      Rails.logger.error "Erro ao carregar HtmlSanitizerService: #{e.message}"
      render json: { error: "Erro interno do servidor ao processar o HTML" }, status: :internal_server_error
      return
    rescue => e
      Rails.logger.error "Erro ao sanitizar HTML: #{e.message}"
      render json: { error: "Erro ao processar o HTML: #{e.message}" }, status: :unprocessable_entity
      return
    end

    if document.save
      render json: {
        message: "Documento salvo com sucesso!",
        document: document
      }, status: :created
    else
      render json: {
        errors: document.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def index
    documents = Document.all
    render json: documents
  end

  def show
    document = Document.find(params[:id])
    render json: document
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Documento não encontrado" }, status: :not_found
  end

  private

  def document_params
    params.require(:document).permit(:username, :html_content)
  end
end
