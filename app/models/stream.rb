# app/models/stream.rb

class Stream < ApplicationRecord
  belongs_to :user
  has_many :stream_logs
  has_many :stream_videos
end
