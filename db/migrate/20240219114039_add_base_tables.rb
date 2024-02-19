class AddBaseTables < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.integer :twitch_id
      t.string :twitch_name
      t.timestamps
    end

    create_table :streams do |t|
      t.belongs_to :user, foreign_key: true
      t.integer :twitch_stream_id
      t.integer :max_viewer_count
      t.timestamp :started_at
      t.string :language
      t.string :thumbnail_url
      t.timestamps
    end

    create_table :games do |t|
      t.string :name
      t.timestamps
    end

    create_table :stream_logs do |t|
      t.belongs_to :stream, foreign_key: true
      t.integer :viewer_count
      t.string :title
      t.integer :game_id
      t.boolean :is_mature
      t.timestamps
    end

    create_table :stream_videos do |t|
      t.integer :vod_id, comment: 'twitch video id'
      t.belongs_to :user, foreign_key: true
      t.belongs_to :stream, foreign_key: true
      t.integer :view_count
      t.string :duration
      t.string :thumbnail_url
      t.string :url
      t.datetime :published_at
      t.string :title
      t.timestamps
    end
  end
end
