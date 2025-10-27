# Services

## HtmlSanitizerService

Serviço responsável por limpar e sanitizar conteúdo HTML, mantendo apenas as tags relacionadas a texto e removendo elementos interativos, scripts, estilos e outros elementos não relacionados ao conteúdo textual.

### Objetivo

Limpar HTML recebido de documentos externos, mantendo apenas o conteúdo textual estruturado, ideal para:
- Extração de conteúdo para leitura
- Remoção de elementos de navegação, formulários e interatividade
- Preparação de conteúdo para análise ou processamento

### Tags Mantidas

O serviço mantém as seguintes tags:

**Estrutura e Semântica:**
- `div`, `article`, `section`, `aside`, `header`, `footer`, `main`

**Headings:**
- `h1`, `h2`, `h3`, `h4`, `h5`, `h6`

**Texto:**
- `p`, `span`, `br`, `hr`

**Formatação:**
- `strong`, `b`, `em`, `i`, `u`, `mark`, `small`, `del`, `ins`, `sub`, `sup`

**Listas:**
- `ul`, `ol`, `li`, `dl`, `dt`, `dd`

**Citações:**
- `blockquote`, `cite`, `q`

**Código:**
- `pre`, `code`, `kbd`, `samp`, `var`

**Outros:**
- `abbr`, `dfn`, `time`

**Tabelas:**
- `table`, `thead`, `tbody`, `tfoot`, `tr`, `th`, `td`, `caption`

### Tags Removidas

- Scripts: `<script>`, `<noscript>`
- Estilos: `<style>`, `<link rel="stylesheet">`
- Formulários: `<form>`, `<input>`, `<textarea>`, `<select>`, `<button>`, `<label>`, `<fieldset>`, `<legend>`
- Links: `<a>` (o texto é mantido)
- Imagens: `<img>`, `<picture>`, `<svg>`, `<video>`, `<audio>`, `<iframe>`, `<embed>`, `<object>`
- Meta tags: `<meta>`, `<head>`, `<title>`, `<base>`
- Navegação: `<nav>` (mas mantém o conteúdo dentro)
- Outros: `<canvas>`, `<map>`, `<area>`, `<template>`, `<slot>`

### Atributos

Apenas os seguintes atributos são mantidos:
- `id`
- `class`
- `lang`
- `dir`

Todos os outros atributos são removidos (incluindo `style`, `onclick`, `href`, `src`, etc).

### Uso

#### No Controller (já integrado)

O serviço está automaticamente integrado no `Api::DocumentsController` e será executado sempre que um documento for criado:

```ruby
# POST /api/documents
# O HTML será automaticamente sanitizado antes de salvar
{
  "document": {
    "username": "usuario",
    "html_content": "<div><h1>Título</h1><script>alert('xss')</script></div>"
  }
}
```

#### Uso Direto

```ruby
# Exemplo básico
html = "<div><h1>Título</h1><script>alert('test')</script><p>Conteúdo</p></div>"
sanitized = HtmlSanitizerService.new(html).call
# Resultado: "<div><h1>Título</h1><p>Conteúdo</p></div>"

# Exemplo com links
html = "<p>Visite nosso <a href='https://site.com'>site</a>!</p>"
sanitized = HtmlSanitizerService.new(html).call
# Resultado: "<p>Visite nosso site!</p>"

# Exemplo com formulário
html = "<form><input type='text'><button>Enviar</button></form><p>Texto</p>"
sanitized = HtmlSanitizerService.new(html).call
# Resultado: "<p>Texto</p>"
```

#### Em outros contextos

```ruby
# No console Rails
html_content = File.read('documento.html')
clean_html = HtmlSanitizerService.new(html_content).call

# Em um job
class ProcessDocumentJob < ApplicationJob
  def perform(document_id)
    document = Document.find(document_id)
    document.html_content = HtmlSanitizerService.new(document.html_content).call
    document.save
  end
end

# Como callback no model
class Document < ApplicationRecord
  before_save :sanitize_html

  private

  def sanitize_html
    self.html_content = HtmlSanitizerService.new(html_content).call
  end
end
```

### Comportamento Especial

1. **Tags vazias**: São removidas automaticamente após a limpeza
2. **Comentários HTML**: São removidos
3. **Links**: A tag `<a>` é removida mas o texto interno é preservado
4. **Tags não permitidas**: São substituídas pelo seu conteúdo interno (unwrapped)

### Testes

Execute os testes do serviço:

```bash
rails test test/services/html_sanitizer_service_test.rb
```

### Notas de Segurança

- O serviço usa Nokogiri para parsing seguro do HTML
- Remove automaticamente scripts e handlers de eventos
- Remove atributos potencialmente perigosos (onclick, onerror, etc)
- Ideal para prevenir XSS em conteúdo de terceiros
