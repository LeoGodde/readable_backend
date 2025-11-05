require "test_helper"

class Api::ArticlesControllerTest < ActionDispatch::IntegrationTest
  # ===== TESTES DO CREATE (POST) =====

  test "deve criar article com dados válidos" do
    assert_difference("Article.count", 1) do
      post api_articles_url, params: {
        article: {
          username: "leo",
          url: "https://www.google.com",
          title: "Google Search"
        }
      }, as: :json
    end

    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal "URL salva com sucesso!", json_response["message"]
    assert_equal "leo", json_response["article"]["username"]
    assert_equal "https://www.google.com", json_response["article"]["url"]
    assert_equal "Google Search", json_response["article"]["title"]
  end

  test "não deve criar article sem username" do
    assert_no_difference("Article.count") do
      post api_articles_url, params: {
        article: {
          url: "https://www.google.com",
          title: "Google Search"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Username can't be blank"
  end

  test "não deve criar article sem url" do
    assert_no_difference("Article.count") do
      post api_articles_url, params: {
        article: {
          username: "leo",
          title: "Google Search"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Url can't be blank"
  end

  test "não deve criar article sem title" do
    assert_no_difference("Article.count") do
      post api_articles_url, params: {
        article: {
          username: "leo",
          url: "https://www.google.com"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Title can't be blank"
  end

  test "não deve criar article vazia" do
    assert_no_difference("Article.count") do
      post api_articles_url, params: {
        article: {}
      }, as: :json
    end

    assert_response :bad_request
  end

  test "não deve criar article com múltiplos erros" do
    assert_no_difference("Article.count") do
      post api_articles_url, params: {
        article: {
          username: "",
          url: "",
          title: ""
        }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Username can't be blank"
    assert_includes json_response["errors"], "Url can't be blank"
    assert_includes json_response["errors"], "Title can't be blank"
  end

  # ===== TESTES DO INDEX (GET ALL) =====

  test "deve listar todas as articles" do
    get api_articles_url, as: :json

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response
    assert json_response.length >= 2
  end

  test "lista vazia deve retornar array vazio" do
    Article.destroy_all

    get api_articles_url, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end

  # ===== TESTES DO SHOW (GET ONE) =====

  test "deve mostrar uma article específica" do
    article = articles(:valid_article)

    get api_article_url(article), as: :json

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal article.id, json_response["id"]
    assert_equal article.username, json_response["username"]
    assert_equal article.url, json_response["url"]
    assert_equal article.title, json_response["title"]
  end

  test "deve retornar erro 404 para article inexistente" do
    get api_article_url(id: 99999), as: :json

    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_equal "Article não encontrada", json_response["error"]
  end

  # ===== TESTES DE VALIDAÇÃO DE URL =====

  test "deve aceitar URLs válidas" do
    valid_urls = [
      "https://www.google.com",
      "http://example.com",
      "https://subdomain.example.com/path?query=value",
      "https://example.com:8080/path"
    ]

    valid_urls.each do |url|
      assert_difference("Article.count", 1) do
        post api_articles_url, params: {
          article: {
            username: "test",
            url: url,
            title: "Test Title"
          }
        }, as: :json
      end

      assert_response :created
      Article.last.destroy # limpa para próximo teste
    end
  end

  # ===== TESTES DE PERFORMANCE =====

  test "deve criar article rapidamente" do
    start_time = Time.current

    post api_articles_url, params: {
      article: {
        username: "leo",
        url: "https://www.google.com",
        title: "Google Search"
      }
    }, as: :json

    end_time = Time.current
    duration = end_time - start_time

    assert_response :created
    assert duration < 1.second, "Criação deve ser rápida (< 1 segundo)"
  end

  test "deve reprocessar article" do
    article = articles(:valid_article)

    post api_reprocess_article_url(article), as: :json

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal "Article reprocessada com sucesso!", json_response["message"]
    assert_equal article.id, json_response["article"]["id"]
    assert_equal article.username, json_response["article"]["username"]
    assert_equal article.url, json_response["article"]["url"]
    assert_equal article.title, json_response["article"]["title"]
    assert_not_nil json_response["article"]["html_content"]
    assert_equal "completed", json_response["article"]["status"]
  end
end
