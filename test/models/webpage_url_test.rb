require "test_helper"

class WebpageUrlTest < ActiveSupport::TestCase
  test "webpage url válida deve ser salva" do
    webpage_url = WebpageUrl.new(
      username: "teste",
      url: "https://www.google.com",
      title: "title"
    )
    assert webpage_url.valid?, "Webpage URL deveria ser válido"
    assert webpage_url.save, "Webpage URL deveria ser salvo"
  end

  test "webpage url nao pode ser salvo sem username" do
    webpage_url = WebpageUrl.new(
      url: "https://www.google.com",
      title: "title"
    )
    assert_not webpage_url.valid?, "Webpage URL sem username não deveria ser válido"
    assert_includes webpage_url.errors[:username], "can't be blank"
  end

  test "webpage url nao pode ser salvo sem url" do
    webpage_url = WebpageUrl.new(
      username: "teste",
      title: "title"
    )
    assert_not webpage_url.valid?, "Webpage URL sem url não deveria ser válido"
    assert_includes webpage_url.errors[:url], "can't be blank"
  end

  test "webpage url nao pode ser salvo sem title" do
    webpage_url = WebpageUrl.new(
      username: "teste",
      url: "https://www.google.com"
    )
    assert_not webpage_url.valid?, "Webpage URL sem title não deveria ser válido"
    assert_includes webpage_url.errors[:title], "can't be blank"
  end

  test "webpage url deve ser salvo com timestamps" do
    webpage_url = WebpageUrl.create!(
      username: "teste",
      url: "https://www.google.com",
      title: "title"
    )
    assert_not_nil webpage_url.created_at
    assert_not_nil webpage_url.updated_at
  end
end
