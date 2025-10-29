require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "webpage url válida deve ser salva" do
    article = Article.new(
      username: "teste",
      url: "https://www.google.com",
      title: "title"
    )
    assert article.valid?, "Webpage URL deveria ser válido"
    assert article.save, "Webpage URL deveria ser salvo"
  end

  test "webpage url nao pode ser salvo sem username" do
    article = Article.new(
      url: "https://www.google.com",
      title: "title"
    )
    assert_not article.valid?, "Webpage URL sem username não deveria ser válido"
    assert_includes article.errors[:username], "can't be blank"
  end

  test "webpage url nao pode ser salvo sem url" do
    article = Article.new(
      username: "teste",
      title: "title"
    )
    assert_not article.valid?, "Webpage URL sem url não deveria ser válido"
    assert_includes article.errors[:url], "can't be blank"
  end

  test "webpage url nao pode ser salvo sem title" do
    article = Article.new(
      username: "teste",
      url: "https://www.google.com"
    )
    assert_not article.valid?, "Webpage URL sem title não deveria ser válido"
    assert_includes article.errors[:title], "can't be blank"
  end

  test "webpage url deve ser salvo com timestamps" do
    article = Article.create!(
      username: "teste",
      url: "https://www.google.com",
      title: "title"
    )
    assert_not_nil article.created_at
    assert_not_nil article.updated_at
  end
end
