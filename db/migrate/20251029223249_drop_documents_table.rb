class DropDocumentsTable < ActiveRecord::Migration[8.1]
  def change
    drop_table :documents if table_exists?(:documents)
  end
end
