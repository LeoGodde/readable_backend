class Article < ApplicationRecord
  validates :username, presence: true
  validates :url, presence: true
  validates :title, presence: true

  after_create :fetch_html_and_sanitize

  private

  def fetch_html_and_sanitize
    FetchHtmlAndSanitizeJob.perform_later(self.id, self.url)
  end
end
