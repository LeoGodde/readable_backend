class Document < ApplicationRecord
  validates :username, presence: true
  validates :html_content, presence: true
end
