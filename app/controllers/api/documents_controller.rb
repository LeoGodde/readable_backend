class Api::DocumentsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    document = Document.new(document_params)

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
