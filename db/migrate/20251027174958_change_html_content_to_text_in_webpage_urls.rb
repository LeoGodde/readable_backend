class ChangeHtmlContentToTextInWebpageUrls < ActiveRecord::Migration[8.1]
  def change
    change_column :webpage_urls, :html_content, :text
  end
end
