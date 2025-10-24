require "test_helper"

class Api::DocumentsControllerTest < ActionDispatch::IntegrationTest
  test "deve criar documento com dados válidos" do
    assert_difference("Document.count", 1) do
      post api_documents_url, params: {
        document: {
          username: "paulo",
          html_content: "<h1>Meu HTML</h1>"
        }
      }, as: :json
    end

    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal "Documento salvo com sucesso!", json_response["message"]
    assert_equal "paulo", json_response["document"]["username"]
    assert_equal "<h1>Meu HTML</h1>", json_response["document"]["html_content"]
  end

  test "não deve criar documento sem username" do
    assert_no_difference("Document.count") do
      post api_documents_url, params: {
        document: {
          html_content: "<h1>HTML sem usuário</h1>"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Username can't be blank"
  end

  test "não deve criar documento sem html_content" do
    assert_no_difference("Document.count") do
      post api_documents_url, params: {
        document: {
          username: "paulo"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Html content can't be blank"
  end

  test "não deve criar documento vazio" do
    assert_no_difference("Document.count") do
      post api_documents_url, params: {
        document: {}
      }, as: :json
    end

    assert_response :bad_request
  end

  # ===== TESTES DO INDEX (GET ALL) =====

  test "deve listar todos os documentos" do
    get api_documents_url, as: :json

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response
    assert json_response.length >= 2
  end

  test "lista vazia deve retornar array vazio" do
    Document.destroy_all

    get api_documents_url, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end

  # ===== TESTES DO SHOW (GET ONE) =====

  test "deve mostrar um documento específico" do
    document = documents(:valid_document)

    get api_document_url(document), as: :json

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal document.id, json_response["id"]
    assert_equal document.username, json_response["username"]
    assert_equal document.html_content, json_response["html_content"]
  end

  test "deve retornar erro 404 para documento inexistente" do
    get api_document_url(id: 99999), as: :json

    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_equal "Documento não encontrado", json_response["error"]
  end
end
