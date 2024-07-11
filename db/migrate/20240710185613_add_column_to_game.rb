class AddColumnToGame < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :twitch_id, :integer, null: true
  end
end
