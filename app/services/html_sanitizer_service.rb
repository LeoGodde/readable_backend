# frozen_string_literal: true

# Serviço responsável por limpar HTML, mantendo apenas tags relacionadas a texto
# Remove scripts, styles, forms, imagens, links e outras tags não relacionadas a conteúdo textual
class HtmlSanitizerService
  # Tags permitidas - apenas elementos de texto e estrutura de conteúdo
  ALLOWED_TAGS = %w[
    p span div
    h1 h2 h3 h4 h5 h6
    ul ol li
    strong b em i u mark small del ins sub sup
    blockquote cite q
    pre code kbd samp var
    abbr dfn time
    dl dt dd
    article section aside
    header footer main
    table thead tbody tfoot tr th td caption
    br hr
  ].freeze

  # Atributos permitidos (mínimos, apenas para contexto)
  ALLOWED_ATTRIBUTES = %w[
    id
    lang
    dir
  ].freeze

  def initialize(html_content)
    @html_content = html_content
  end

  # Método principal que executa a sanitização
  def call
    return "" if @html_content.blank?

    doc = Nokogiri::HTML.fragment(@html_content)

    sanitize_node(doc)

    # Remove tags vazias recursivamente
    remove_empty_tags(doc)

    # Remove quebras de linha
    doc.to_html.strip.gsub(/\n/, "")
  end

  private

  def sanitize_node(node)
    # Remove comments
    node.xpath(".//comment()").remove

    # Remove scripts, styles, forms, buttons, inputs, etc
    remove_unwanted_tags(node)

    # Remove links mas mantém o conteúdo textual
    unwrap_links(node)

    # Remove imagens
    node.css("img, picture, svg, video, audio, iframe, embed, object").remove

    # Limpa atributos não permitidos
    clean_attributes(node)

    node
  end

  def remove_unwanted_tags(node)
    unwanted_tags = %w[
      script style link meta
      form input textarea select button label fieldset legend
      canvas map area
      base head title
      noscript template slot
      nav
    ]

    node.css(unwanted_tags.join(", ")).remove
  end

  def unwrap_links(node)
    # Remove a tag <a> mas mantém o texto interno
    node.css("a").each do |link|
      link.replace(link.inner_html)
    end
  end

  def clean_attributes(node)
    node.css("*").each do |element|
      # Remove todos os atributos não permitidos
      element.attributes.each_key do |attr|
        element.remove_attribute(attr) unless ALLOWED_ATTRIBUTES.include?(attr)
      end

      # Remove tags que não estão na whitelist (mas mantém o conteúdo)
      unless ALLOWED_TAGS.include?(element.name.downcase)
        element.replace(element.inner_html) if element.name != "document"
      end
    end
  end

  def remove_empty_tags(node)
    # Remove tags vazias ou que contém apenas espaços em branco
    loop do
      empty_tags = node.css("*").select do |element|
        next false if %w[br hr].include?(element.name.downcase) # Mantém tags auto-fechadas

        element.content.strip.empty? && element.children.empty?
      end

      break if empty_tags.empty?

      empty_tags.each(&:remove)
    end
  end
end
