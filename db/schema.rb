# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_07_11_085025) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "twitch_id"
  end

  create_table "stream_logs", force: :cascade do |t|
    t.bigint "stream_id"
    t.integer "viewer_count"
    t.string "title"
    t.integer "game_id"
    t.boolean "is_mature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stream_id"], name: "index_stream_logs_on_stream_id"
  end

  create_table "stream_videos", force: :cascade do |t|
    t.integer "vod_id", comment: "twitch video id"
    t.bigint "user_id"
    t.bigint "stream_id"
    t.integer "view_count"
    t.string "duration"
    t.string "thumbnail_url"
    t.string "url"
    t.datetime "published_at"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stream_id"], name: "index_stream_videos_on_stream_id"
    t.index ["user_id"], name: "index_stream_videos_on_user_id"
  end

  create_table "streams", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "twitch_stream_id"
    t.integer "max_viewer_count"
    t.datetime "started_at", precision: nil
    t.string "language"
    t.string "thumbnail_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "ended_at"
    t.string "title"
    t.index ["user_id"], name: "index_streams_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "twitch_id"
    t.string "twitch_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sully_streamer_id"
  end

  add_foreign_key "stream_logs", "games"
  add_foreign_key "stream_logs", "streams"
  add_foreign_key "stream_videos", "streams"
  add_foreign_key "stream_videos", "users"
  add_foreign_key "streams", "users"
end
