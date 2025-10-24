class Api::DocumentsController < ApplicationController
  # Pula a verificação de token CSRF para APIs
  skip_before_action :verify_authenticity_token

  # POST /api/documents
  def create
    # Cria um novo documento com os dados recebidos
    document = Document.new(document_params)

    # Tenta salvar no banco
    if document.save
      # Se salvou com sucesso, retorna JSON com status 201
      render json: {
        message: "Documento salvo com sucesso!",
        document: document
      }, status: :created
    else
      # Se deu erro, retorna os erros com status 422
      render json: {
        errors: document.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # GET /api/documents (listar todos)
  def index
    documents = Document.all
    render json: documents
  end

  # GET /api/documents/:id (ver um específico)
  def show
    document = Document.find(params[:id])
    render json: document
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Documento não encontrado" }, status: :not_found
  end

  private

  # Define quais parâmetros são permitidos (segurança)
  def document_params
    params.require(:document).permit(:username, :html_content)
  end
end
