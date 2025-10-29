class RenameWebpageUrlsToArticles < ActiveRecord::Migration[8.1]
  def change
    rename_table :webpage_urls, :articles
  end
end
