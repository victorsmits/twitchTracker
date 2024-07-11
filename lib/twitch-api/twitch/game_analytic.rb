# frozen_string_literal: true

module Twitch
  # Data object for `/analytics/games` requests
  class GameAnalytic
    # ID of the game requested.
    attr_reader :game_id
    # A link to a (CSV format) data report.
    attr_reader :url

    def initialize(attributes = {})
      @game_id = attributes['game_id']
      @url = attributes['URL']
    end
  end
end
