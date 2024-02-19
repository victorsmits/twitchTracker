class UpdateStreamColumnType < ActiveRecord::Migration[7.1]
  def up
    change_column :streams, :twitch_stream_id, :bigint
  end
end
