class AddColumnTitleToStream < ActiveRecord::Migration[7.1]
  def change
    add_column :streams, :title, :string, null: true
  end
end
