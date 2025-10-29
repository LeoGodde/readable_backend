class AddsHtmlBodyToWebpageUrls < ActiveRecord::Migration[8.1]
  def change
    add_column :webpage_urls, :html_content, :string
    add_column :webpage_urls, :status, :text, default: 'pending'
  end
end
