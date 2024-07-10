class AddRelationBetweenGameAndLog < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :stream_logs, :games
  end
end
