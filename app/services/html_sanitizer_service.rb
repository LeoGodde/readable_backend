# frozen_string_literal: true

class HtmlSanitizerService
  #
  ALLOWED_TAGS = %w[
    p span div
    h1 h2 h3 h4 h5 h6
    ul ol li
    strong b em i u small del ins sub sup
    blockquote cite q
    pre code kbd samp var
    abbr dfn time
    dl dt dd
    article section aside
    header footer main
    table thead tbody tfoot tr th td caption
    br
  ].freeze


  ALLOWED_ATTRIBUTES = %w[
    lang
    dir
  ].freeze

  def initialize(html_content)
    @html_content = html_content
  end


  def call
    return "" if @html_content.blank?

    doc = Nokogiri::HTML.fragment(@html_content)

    sanitize_node(doc)

    remove_empty_tags(doc)

    html = doc.to_html.strip
      .gsub(/\n/, "")
      .gsub(/\t/, "")
      .gsub(/\s+/, " ")

    remove_empty_html_tags(html)
  end

  private

  def sanitize_node(node)
    node.xpath(".//comment()").remove

    remove_unwanted_tags(node)

    unwrap_links(node)

    node.css("img, picture, svg, video, audio, iframe, embed, object").remove

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
    node.css("a").each do |link|
      link.replace(link.inner_html)
    end
  end

  def clean_attributes(node)
    node.css("*").each do |element|
      element.attributes.each_key do |attr|
        element.remove_attribute(attr) unless ALLOWED_ATTRIBUTES.include?(attr)
      end


      unless ALLOWED_TAGS.include?(element.name.downcase)
        element.replace(element.inner_html) if element.name != "document"
      end
    end
  end

  def remove_empty_tags(node)
    loop do
      empty_tags = node.css("*").select do |element|
        next false if %w[br hr].include?(element.name.downcase)

        element.content.strip.empty? && element.children.empty?
      end

      break if empty_tags.empty?

      empty_tags.each(&:remove)
    end
  end


  def remove_empty_html_tags(html)
    loop do
      initial = html

      html = html.gsub(/<(\w+)>\s*<\/\1>/, "")

      break if html == initial
    end

    html
  end
end
