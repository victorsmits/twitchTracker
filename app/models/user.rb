# app/models/user.rb

class User < ApplicationRecord
  has_many :streams
  has_many :stream_videos
end