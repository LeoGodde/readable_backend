require "test_helper"

class Api::WebpageUrlsControllerTest < ActionDispatch::IntegrationTest
  # ===== TESTES DO CREATE (POST) =====

  test "deve criar webpage_url com dados válidos" do
    assert_difference("WebpageUrl.count", 1) do
      post api_webpage_urls_url, params: {
        webpage_url: {
          username: "leo",
          url: "https://www.google.com",
          title: "Google Search"
        }
      }, as: :json
    end

    assert_response :created

    json_response = JSON.parse(response.body)
    assert_equal "URL salva com sucesso!", json_response["message"]
    assert_equal "leo", json_response["webpage_url"]["username"]
    assert_equal "https://www.google.com", json_response["webpage_url"]["url"]
    assert_equal "Google Search", json_response["webpage_url"]["title"]
  end

  test "não deve criar webpage_url sem username" do
    assert_no_difference("WebpageUrl.count") do
      post api_webpage_urls_url, params: {
        webpage_url: {
          url: "https://www.google.com",
          title: "Google Search"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Username can't be blank"
  end

  test "não deve criar webpage_url sem url" do
    assert_no_difference("WebpageUrl.count") do
      post api_webpage_urls_url, params: {
        webpage_url: {
          username: "leo",
          title: "Google Search"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Url can't be blank"
  end

  test "não deve criar webpage_url sem title" do
    assert_no_difference("WebpageUrl.count") do
      post api_webpage_urls_url, params: {
        webpage_url: {
          username: "leo",
          url: "https://www.google.com"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Title can't be blank"
  end

  test "não deve criar webpage_url vazia" do
    assert_no_difference("WebpageUrl.count") do
      post api_webpage_urls_url, params: {
        webpage_url: {}
      }, as: :json
    end

    assert_response :bad_request
  end

  test "não deve criar webpage_url com múltiplos erros" do
    assert_no_difference("WebpageUrl.count") do
      post api_webpage_urls_url, params: {
        webpage_url: {
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

  test "deve listar todas as webpage_urls" do
    get api_webpage_urls_url, as: :json

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_kind_of Array, json_response
    assert json_response.length >= 2
  end

  test "lista vazia deve retornar array vazio" do
    WebpageUrl.destroy_all

    get api_webpage_urls_url, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal [], json_response
  end

  # ===== TESTES DO SHOW (GET ONE) =====

  test "deve mostrar uma webpage_url específica" do
    webpage_url = webpage_urls(:valid_webpage_url)

    get api_webpage_url_url(webpage_url), as: :json

    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal webpage_url.id, json_response["id"]
    assert_equal webpage_url.username, json_response["username"]
    assert_equal webpage_url.url, json_response["url"]
    assert_equal webpage_url.title, json_response["title"]
  end

  test "deve retornar erro 404 para webpage_url inexistente" do
    get api_webpage_url_url(id: 99999), as: :json

    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_equal "Webpage URL não encontrada", json_response["error"]
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
      assert_difference("WebpageUrl.count", 1) do
        post api_webpage_urls_url, params: {
          webpage_url: {
            username: "test",
            url: url,
            title: "Test Title"
          }
        }, as: :json
      end

      assert_response :created
      WebpageUrl.last.destroy # limpa para próximo teste
    end
  end

  # ===== TESTES DE PERFORMANCE =====

  test "deve criar webpage_url rapidamente" do
    start_time = Time.current

    post api_webpage_urls_url, params: {
      webpage_url: {
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
end
