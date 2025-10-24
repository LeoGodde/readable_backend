class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.string :username
      t.text :html_content

      t.timestamps
    end
  end
end
