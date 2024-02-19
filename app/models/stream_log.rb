# app/models/stream_log.rb

class StreamLog < ApplicationRecord
  belongs_to :stream
  belongs_to :game
end
