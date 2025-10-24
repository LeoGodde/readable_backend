class WebpageUrl < ApplicationRecord
  validates :username, presence: true
  validates :url, presence: true
  validates :title, presence: true
end
