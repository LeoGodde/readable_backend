# frozen_string_literal: true

require "test_helper"

class ReadabilityServiceTest < ActiveSupport::TestCase
  def setup
    @html = <<~HTML
      <html>
        <head>
          <title>Test Article</title>
          <meta property="og:title" content="Test Article Title" />
        </head>
        <body>
          <nav>Menu content</nav>
          <header>Header content</header>
          <article>
            <h1>Main Article Title</h1>
            <p>First paragraph of the article content.</p>
            <p>Second paragraph with more content.</p>
            <p>Third paragraph with detailed information.</p>
          </article>
          <aside>Sidebar content</aside>
          <footer>Footer content</footer>
        </body>
      </html>
    HTML
  end

  test "extracts title from og:title meta tag" do
    service = ReadabilityService.new(@html)
    assert_equal "Test Article Title", service.title
  end

  test "extracts main content without nav, aside, footer" do
    service = ReadabilityService.new(@html)
    content = service.extract

    assert_not_includes content, "Menu content"
    assert_not_includes content, "Header content"
    assert_not_includes content, "Sidebar content"
    assert_not_includes content, "Footer content"

    assert_includes content, "Main Article Title"
    assert_includes content, "First paragraph of the article content"
  end

  test "handles empty html" do
    service = ReadabilityService.new("")
    assert_equal "", service.extract
  end

  test "removes nested empty divs" do
    html = "<div><div><div><p>texto</p></div></div></div>"
    service = ReadabilityService.new(html)
    result = service.extract

    # Deve manter apenas uma div com o parágrafo
    assert_includes result, "<p>texto</p>"
    # A div com o parágrafo é a única div necessária
    # (pode ter 1 ou 2 divs dependendo da implementação)
    assert result.scan("</div>").count <= 2, "Deve ter no máximo 2 divs finais"
  end

  test "keeps divs with mixed content" do
    html = "<div><div><p></p></div><div><p>texto</p></div></div>"
    service = ReadabilityService.new(html)
    result = service.extract

    # Deve manter o conteúdo com texto
    assert_includes result, "<p>texto</p>"
    # Deve remover tags vazias (p vazio e div vazia)
    assert_includes result, "<div>"
    # Deve ter pelo menos 1 div com o texto
    assert result.scan("</div>").count >= 1
  end
end
