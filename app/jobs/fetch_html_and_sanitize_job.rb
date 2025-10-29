class FetchHtmlAndSanitizeJob < ApplicationJob
  queue_as :default

  def perform(webpage_url_id, url)
    webpage_url = WebpageUrl.find(webpage_url_id)

    require "net/http"
    require "uri"

    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.read_timeout = 30
    http.open_timeout = 10

    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "Mozilla/5.0 (compatible; ReadableBot/1.0)"

    response = http.request(request)

    if response.code.to_i == 200
      readability = ReadabilityService.new(response.body)
      extracted_title = readability.title
      main_content = readability.extract

      sanitized_html = HtmlSanitizerService.new(main_content).call

      webpage_url.update!(
        title: extracted_title,
        html_content: sanitized_html,
        status: "completed"
      )

    else
      webpage_url.update!(
        status: "failed",
        html_content: "Error: #{response.message}"
      )
    end

  rescue StandardError => e
    webpage_url&.update!(
      status: "failed",
      html_content: "Error: #{e.message}"
    )
  end
end
