class CreateWebpageUrls < ActiveRecord::Migration[8.1]
  def change
    create_table :webpage_urls do |t|
      t.string :url
      t.string :title
      t.string :username

      t.timestamps
    end
  end
end
