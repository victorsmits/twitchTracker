class UpdateUserAndStreams < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :sully_streamer_id, :integer
  end
end
