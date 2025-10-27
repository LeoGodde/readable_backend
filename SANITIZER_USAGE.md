# Guia de Uso - HTML Sanitizer

Este guia mostra como usar o serviço de sanitização de HTML na API de documentos do Readable.

## Como Funciona

Quando você envia um documento HTML via API, o `HtmlSanitizerService` automaticamente:

1. ✅ **Mantém** tags de texto e estrutura de conteúdo (h1-h6, p, ul, li, strong, em, etc)
2. ❌ **Remove** scripts, styles, formulários, buttons, inputs
3. ❌ **Remove** imagens, videos, iframes
4. ❌ **Remove** navegação e menus (nav)
5. 🔄 **Converte** links (`<a>`) em texto puro (mantém o texto, remove o link)
6. 🧹 **Limpa** atributos perigosos (onclick, style, etc)

## Testando via API

### 1. Criar um documento com HTML complexo

```bash
curl -X POST http://localhost:3000/api/documents \
  -H "Content-Type: application/json" \
  -d '{
    "document": {
      "username": "leogodde",
      "html_content": "<!doctype html><html><head><style>body{color:red;}</style></head><body><h1>Título</h1><script>alert(\"XSS\");</script><p>Conteúdo <strong>importante</strong>.</p><form><input type=\"text\"><button>Enviar</button></form><img src=\"test.jpg\"><nav><ul><li><a href=\"#\">Link</a></li></ul></nav></body></html>"
    }
  }'
```

**Resposta esperada:**
```json
{
  "message": "Documento salvo com sucesso!",
  "document": {
    "id": 1,
    "username": "leogodde",
    "html_content": "<h1>Título</h1><p>Conteúdo <strong>importante</strong>.</p>",
    "created_at": "2025-10-24T...",
    "updated_at": "2025-10-24T..."
  }
}
```

Note como:
- ❌ `<style>`, `<script>`, `<form>`, `<input>`, `<button>`, `<img>`, `<nav>` foram removidos
- ✅ `<h1>`, `<p>`, `<strong>` foram mantidos
- 🔄 O link dentro do `<nav>` foi removido completamente

### 2. Testar com o HTML de exemplo completo

```bash
# Salve o HTML em um arquivo
cat > /tmp/sample.html << 'EOF'
<!doctype html>
<html lang="pt-BR">
<head>
  <style>body{color:red;}</style>
</head>
<body>
  <header>
    <h1>Lorem Ipsum</h1>
    <p>Documento de exemplo</p>
  </header>

  <nav>
    <ul>
      <li><a href="#intro">Introdução</a></li>
    </ul>
  </nav>

  <main>
    <h2>Introdução</h2>
    <p><strong>Lorem ipsum</strong> dolor sit amet.</p>

    <form>
      <input type="text">
      <button>Enviar</button>
    </form>

    <img src="test.jpg">

    <ul>
      <li>Item 1</li>
      <li>Item 2</li>
    </ul>

    <table>
      <tr><th>Cabeçalho</th></tr>
      <tr><td>Dado</td></tr>
    </table>
  </main>
</body>
</html>
EOF

# Enviar via curl (escapa o JSON)
HTML_CONTENT=$(cat /tmp/sample.html | jq -Rs .)

curl -X POST http://localhost:3000/api/documents \
  -H "Content-Type: application/json" \
  -d "{\"document\":{\"username\":\"teste\",\"html_content\":$HTML_CONTENT}}"
```

## Testando no Console do Rails

```ruby
# Abra o console
rails console

# Exemplo 1: HTML com scripts e styles
html = <<~HTML
  <div>
    <h1>Título</h1>
    <script>alert('XSS');</script>
    <style>body { color: red; }</style>
    <p>Conteúdo válido</p>
  </div>
HTML

sanitized = HtmlSanitizerService.new(html).call
puts sanitized
# Output:
# <div>
#   <h1>Título</h1>
#   <p>Conteúdo válido</p>
# </div>

# Exemplo 2: HTML com links e formulários
html = <<~HTML
  <article>
    <h2>Artigo</h2>
    <p>Visite nosso <a href="https://exemplo.com">site</a>.</p>
    <form>
      <input type="text" name="email">
      <button>Cadastrar</button>
    </form>
    <p>Mais conteúdo aqui.</p>
  </article>
HTML

sanitized = HtmlSanitizerService.new(html).call
puts sanitized
# Output:
# <article>
#   <h2>Artigo</h2>
#   <p>Visite nosso site.</p>
#   <p>Mais conteúdo aqui.</p>
# </article>

# Exemplo 3: Criar documento diretamente
doc = Document.create!(
  username: "teste_console",
  html_content: "<div><h1>Título</h1><script>alert('bad');</script><p>Texto</p></div>"
)

# O HTML já foi sanitizado automaticamente
puts doc.html_content
# Output: <div><h1>Título</h1><p>Texto</p></div>

# Verificar que o script foi removido
doc.html_content.include?('script') # => false
doc.html_content.include?('alert') # => false
```

## Testando com Postman/Insomnia

### Request
```
POST http://localhost:3000/api/documents
Content-Type: application/json

{
  "document": {
    "username": "usuario_teste",
    "html_content": "<html><body><h1>Título</h1><script>console.log('test');</script><p>Parágrafo com <strong>negrito</strong> e <a href='#'>link</a>.</p><button>Clique</button><img src='test.jpg'></body></html>"
  }
}
```

### Response
```json
{
  "message": "Documento salvo com sucesso!",
  "document": {
    "id": 1,
    "username": "usuario_teste",
    "html_content": "<h1>Título</h1><p>Parágrafo com <strong>negrito</strong> e link.</p>",
    "created_at": "2025-10-24T10:00:00.000Z",
    "updated_at": "2025-10-24T10:00:00.000Z"
  }
}
```

## Verificar Resultados

### Listar todos os documentos
```bash
curl http://localhost:3000/api/documents
```

### Ver um documento específico
```bash
curl http://localhost:3000/api/documents/1
```

## Testes Unitários

Execute os testes do serviço:

```bash
# Testar apenas o serviço de sanitização
rails test test/services/html_sanitizer_service_test.rb

# Testar todos os testes
rails test

# Executar com detalhes
rails test test/services/html_sanitizer_service_test.rb -v
```

## Casos de Uso Reais

### 1. Web Scraping - Extrair apenas conteúdo textual
```ruby
# Fazer scraping de uma página web
require 'open-uri'
html = URI.open('https://exemplo.com/artigo').read

# Limpar e obter apenas o conteúdo
clean_html = HtmlSanitizerService.new(html).call

# Salvar no banco
Document.create!(username: "scraper", html_content: html)
```

### 2. Importação de Documentos
```ruby
# Importar múltiplos documentos HTML
Dir.glob('documents/*.html').each do |file|
  html = File.read(file)
  Document.create!(
    username: "importer",
    html_content: html # Será sanitizado automaticamente
  )
end
```

### 3. API Externa
```ruby
# Receber HTML de uma API externa e sanitizar
response = HTTP.get('https://api.exemplo.com/article/123')
html = response.body

doc = Document.create!(
  username: "api_import",
  html_content: html
)
```

## Tags Permitidas (Referência Rápida)

✅ **Estrutura**: div, article, section, aside, header, footer, main
✅ **Headings**: h1, h2, h3, h4, h5, h6
✅ **Texto**: p, span, br, hr
✅ **Formatação**: strong, b, em, i, u, mark, small, del, ins, sub, sup
✅ **Listas**: ul, ol, li, dl, dt, dd
✅ **Citações**: blockquote, cite, q
✅ **Código**: pre, code, kbd, samp, var
✅ **Tabelas**: table, thead, tbody, tfoot, tr, th, td, caption
✅ **Outros**: abbr, dfn, time

❌ **Removidos**: script, style, link, form, input, button, img, video, audio, iframe, nav, a, canvas, map, etc.
