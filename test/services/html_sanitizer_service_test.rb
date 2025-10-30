# frozen_string_literal: true

require "test_helper"

class HtmlSanitizerServiceTest < ActiveSupport::TestCase
  test "remove scripts e styles" do
    html = <<~HTML
      <div>
        <h1>Título</h1>
        <script>alert('malicious');</script>
        <style>.test { color: red; }</style>
        <p>Conteúdo válido</p>
      </div>
    HTML

    result = HtmlSanitizerService.new(html).call

    assert_not_includes result, "script"
    assert_not_includes result, "style"
    assert_not_includes result, "alert"
    assert_includes result, "Título"
    assert_includes result, "Conteúdo válido"
  end

  test "remove formulários e inputs" do
    html = <<~HTML
      <div>
        <h2>Formulário</h2>
        <form action="/test">
          <input type="text" name="nome">
          <button type="submit">Enviar</button>
        </form>
        <p>Texto após formulário</p>
      </div>
    HTML

    result = HtmlSanitizerService.new(html).call

    assert_not_includes result, "<form"
    assert_not_includes result, "<input"
    assert_not_includes result, "<button"
    assert_includes result, "Texto após formulário"
  end

  test "remove imagens mas mantém figcaption" do
    html = <<~HTML
      <figure>
        <img src="test.jpg" alt="Test">
        <figcaption>Legenda da imagem</figcaption>
      </figure>
    HTML

    result = HtmlSanitizerService.new(html).call

    assert_not_includes result, "img"
    assert_not_includes result, "test.jpg"
    # figcaption é mantida pois contém texto
    assert_includes result, "Legenda da imagem"
  end

  test "remove links mas mantém o texto" do
    html = <<~HTML
      <p>Visite nosso <a href="https://exemplo.com">site</a> para mais informações.</p>
    HTML

    result = HtmlSanitizerService.new(html).call

    assert_not_includes result, "<a"
    assert_not_includes result, "href"
    assert_includes result, "site"
    assert_includes result, "Visite nosso"
  end

  test "mantém tags de texto formatação" do
    html = <<~HTML
      <div>
        <p>Texto com <strong>negrito</strong>, <em>itálico</em>, e <u>sublinhado</u>.</p>
        <p>Também destacado e <small>pequeno</small>.</p>
        <code>código inline</code>
      </div>
    HTML

    result = HtmlSanitizerService.new(html).call

    assert_includes result, "<strong>negrito</strong>"
    assert_includes result, "<em>itálico</em>"
    assert_includes result, "<u>sublinhado</u>"
    assert_includes result, "<small>pequeno</small>"
    assert_includes result, "<code>código inline</code>"
  end

  test "mantém estrutura de listas" do
    html = <<~HTML
      <ul>
        <li>Item 1</li>
        <li>Item 2
          <ol>
            <li>Subitem 2.1</li>
            <li>Subitem 2.2</li>
          </ol>
        </li>
        <li>Item 3</li>
      </ul>
    HTML

    result = HtmlSanitizerService.new(html).call

    assert_includes result, "<ul>"
    assert_includes result, "<li>Item 1</li>"
    assert_includes result, "<ol>"
    assert_includes result, "Subitem 2.1"
  end

  test "mantém headings" do
    html = <<~HTML
      <h1>Heading 1</h1>
      <h2>Heading 2</h2>
      <h3>Heading 3</h3>
      <h4>Heading 4</h4>
      <h5>Heading 5</h5>
      <h6>Heading 6</h6>
    HTML

    result = HtmlSanitizerService.new(html).call

    assert_includes result, "<h1>Heading 1</h1>"
    assert_includes result, "<h2>Heading 2</h2>"
    assert_includes result, "<h3>Heading 3</h3>"
    assert_includes result, "<h4>Heading 4</h4>"
    assert_includes result, "<h5>Heading 5</h5>"
    assert_includes result, "<h6>Heading 6</h6>"
  end

  test "mantém blockquotes e citações" do
    html = <<~HTML
      <blockquote>
        <p>Esta é uma citação importante.</p>
        <footer>— <cite>Autor Desconhecido</cite></footer>
      </blockquote>
    HTML

    result = HtmlSanitizerService.new(html).call

    assert_includes result, "<blockquote>"
    assert_includes result, "citação importante"
    assert_includes result, "<cite>"
  end

  test "mantém tabelas" do
    html = <<~HTML
      <table>
        <thead>
          <tr><th>Cabeçalho 1</th><th>Cabeçalho 2</th></tr>
        </thead>
        <tbody>
          <tr><td>Dado 1</td><td>Dado 2</td></tr>
        </tbody>
      </table>
    HTML

    result = HtmlSanitizerService.new(html).call

    assert_includes result, "<table>"
    assert_includes result, "<thead>"
    assert_includes result, "<th>Cabeçalho 1</th>"
    assert_includes result, "<td>Dado 1</td>"
  end

  test "remove atributos não permitidos" do
    html = <<~HTML
      <p style="color: red;" onclick="alert()">Texto com atributos</p>
    HTML

    result = HtmlSanitizerService.new(html).call

    assert_not_includes result, "style="
    assert_not_includes result, "onclick="
    assert_includes result, "Texto com atributos"
  end

  test "remove tags vazias" do
    html = <<~HTML
      <div>
        <p>Conteúdo</p>
        <p></p>
        <span></span>
        <div></div>
      </div>
    HTML

    result = HtmlSanitizerService.new(html).call

    assert_includes result, "<p>Conteúdo</p>"
    # Tags vazias devem ser removidas
    refute_match(/<p>\s*<\/p>/, result)
    refute_match(/<span>\s*<\/span>/, result)
  end

  test "retorna string vazia para html vazio" do
    result = HtmlSanitizerService.new("").call
    assert_equal "", result

    result = HtmlSanitizerService.new(nil).call
    assert_equal "", result
  end

  test "processa html complexo completo" do
    html = File.read(Rails.root.join("test", "fixtures", "files", "sample_document.html")) rescue nil

    # Se o arquivo de exemplo não existir, usa um html inline
    html ||= <<~HTML
      <!doctype html>
      <html>
      <head>
        <style>body { color: red; }</style>
      </head>
      <body>
        <div class="container">
          <header>
            <h1>Título Principal</h1>
          </header>
          <nav>
            <ul>
              <li><a href="#section1">Link 1</a></li>
            </ul>
          </nav>
          <main>
            <article>
              <h2>Seção 1</h2>
              <p><strong>Lorem ipsum</strong> dolor sit amet.</p>
              <img src="test.jpg" alt="Imagem">
              <form>
                <input type="text">
                <button>Enviar</button>
              </form>
            </article>
          </main>
          <footer>
            <p>Rodapé</p>
          </footer>
        </div>
      </body>
      </html>
    HTML

    result = HtmlSanitizerService.new(html).call

    # Deve manter conteúdo textual
    assert_includes result, "Lorem Ipsum"
    assert_includes result, "Documento de Exemplo"
    assert_includes result, "lorem ipsum"

    # Deve remover elementos não textuais
    assert_not_includes result, "<style"
    assert_not_includes result, "<nav"
    assert_not_includes result, "<a "
    assert_not_includes result, "<img"
    assert_not_includes result, "<form"
    assert_not_includes result, "<button"
    assert_not_includes result, "<input"
  end
end
