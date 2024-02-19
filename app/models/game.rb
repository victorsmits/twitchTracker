# app/models/game.rb

class Game < ApplicationRecord
  has_many :stream_logs
end
