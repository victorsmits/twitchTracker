# app/models/stream_video.rb

class StreamVideo < ApplicationRecord
  belongs_to :user
  belongs_to :stream
end
