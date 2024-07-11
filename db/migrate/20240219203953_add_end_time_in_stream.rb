class AddEndTimeInStream < ActiveRecord::Migration[7.1]
  def change
    add_column :streams, :ended_at, :datetime
  end
end
