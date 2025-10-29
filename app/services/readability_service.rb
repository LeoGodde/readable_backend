# frozen_string_literal: true

class ReadabilityService
  def initialize(html_content)
    @doc = Nokogiri::HTML(html_content)
  end

  def extract
    return "" if @doc.nil?

    remove_non_content_areas

    main_content = find_main_content

    main_content ||= clean_remaining_content

    remove_all_classes(main_content)

    remove_empty_tags(main_content)

    cleaned_html = remove_empty_divs(main_content.inner_html)

    cleaned_html.strip
  end

  def title
    title = @doc.at_css("meta[property='og:title']")&.attribute("content")&.value ||
            @doc.at_css("meta[name='title']")&.attribute("content")&.value ||
            @doc.at_css("h1")&.text ||
            @doc.at_css("title")&.text

    title.to_s.strip
  end

  private

  def remove_non_content_areas
    @doc.css("nav, aside, .sidebar, .navigation,
             header:not(:has(article)):not(:has(main)),
             footer, .site-footer,
             .ad, .ads, .advertisement, .sponsored,
             .social, .share, .comments,
             .related, .popular, .trending,
             .cookie, .cookies, .consent,
             form, .form, .search-form").remove

    @doc.css("[class*='menu']:not(:has(article)):not(:has(main)),
             [class*='sidebar']:not(:has(article)):not(:has(main)),
             [class*='footer']:not(:has(article)):not(:has(main)),
             [id*='sidebar']:not(:has(article)):not(:has(main)),
             [id*='footer']:not(:has(article)):not(:has(main))").remove

    @doc.css("button, .button, .btn, input, select, textarea").remove
  end

  def find_main_content
    main = @doc.at_css("article, .article, .content, .post, .entry,
                        main, [role='main']")

    return main if main

    article_div = @doc.css("div").find do |div|
      paragraphs = div.css("p")
      links = div.css("a")

      paragraphs.count >= 3 && (links.count.to_f / (paragraphs.count + 1)) < 0.3
    end

    article_div
  end

  def clean_remaining_content
    @doc.css("body, .wrapper, .main, .container").first || @doc
  end

  def remove_all_classes(element)
    element.css("*").each do |node|
      node.remove_attribute("class") if node.has_attribute?("class")
    end
  end

  def remove_empty_tags(element)
    self_closing_tags = %w[br hr img]

    loop do
      initial_html = element.to_html

      element.css("*").reverse.each do |node|
        next if self_closing_tags.include?(node.name)

        if node_is_empty?(node)
          node.remove
        end
      end

      break if element.to_html == initial_html
    end
  end

  def node_is_empty?(node)
    return false if node.text.strip.length > 0

    node.children.each do |child|
      next if child.text?

      return false if %w[br hr img].include?(child.name)
    end

    true
  end

  def remove_empty_divs(html)
    fragment = Nokogiri::HTML::DocumentFragment.parse(html)

    loop do
      initial_html = fragment.to_html

      fragment.css("div").reverse.each do |div|
        if node_is_empty?(div)
          div.remove
        elsif is_wrapper_div?(div)
          unwrap_div(div)
        end
      end

      break if fragment.to_html == initial_html
    end

    fragment.to_html
  end

  def is_wrapper_div?(div)
    element_children = div.children.select(&:element?)

    return false unless element_children.count == 1

    return false unless element_children.first.name == "div"

    text_children = div.children.select(&:text?)
    return false if text_children.any? { |t| !t.text.strip.empty? }

    true
  end

  def unwrap_div(wrapper)
    inner_div = wrapper.at_css("> div")
    return unless inner_div

    wrapper.replace(inner_div)
  end
end
