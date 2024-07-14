# frozen_string_literal: true

require 'faraday'
require 'faraday/parse_dates'
require 'faraday/retry'
require 'twitch_oauth2'

require_relative 'response'
require_relative 'api_error'
require_relative 'request'

require_relative 'bits_leader'
require_relative 'category'
require_relative 'channel'
require_relative 'cheermote'
require_relative 'clip'
require_relative 'custom_reward'
require_relative 'editor'
require_relative 'entitlement_grant_url'
require_relative 'extension'
require_relative 'extensions_by_types'
require_relative 'game'
require_relative 'game_analytic'
require_relative 'moderation_event'
require_relative 'moderator'
require_relative 'stream'
require_relative 'stream_marker'
require_relative 'stream_metadata'
require_relative 'subscription'
require_relative 'user'
require_relative 'user_ban'
require_relative 'user_follow'
require_relative 'redemption'
require_relative 'video'

module Twitch
  # Core class for requests
  class Client < Request

    attr_reader :tokens

    def create_clip(options = {})
      initialize_response Clip, post('clips', options)
    end

    def create_entitlement_grant_url(options = {})
      initialize_response EntitlementGrantUrl, post('entitlements/upload', options)
    end

    def get_clips(options = {})
      initialize_response Clip, get('clips', options)
    end

    def get_bits_leaderboard(options = {})
      initialize_response BitsLeader, get('bits/leaderboard', options)
    end

    def get_cheermotes(options = {})
      initialize_response Cheermote, get('bits/cheermotes', options)
    end

    require_relative 'client/extensions'
    include Extensions

    require_relative 'client/games'
    include Games

    require_relative 'client/moderation'
    include Moderation

    require_relative 'client/streams'
    include Streams

    require_relative 'client/subscriptions'
    include Subscriptions

    def get_videos(options = {})
      initialize_response Video, get('videos', options)
    end

    require_relative 'client/users'
    include Users

    require_relative 'client/custom_rewards'
    include CustomRewards

    ## https://dev.twitch.tv/docs/api/reference#get-channel-information
    def get_channels(options = {})
      initialize_response Channel, get('channels', options)
    end

    ## https://dev.twitch.tv/docs/api/reference/#search-channels
    def search_channels(options = {})
      initialize_response Channel, get('search/channels', options)
    end

    ## https://dev.twitch.tv/docs/api/reference#modify-channel-information
    def modify_channel(options = {})
      response = patch('channels', options)

      return true if response.body.empty?

      response.body
    end

    ## https://dev.twitch.tv/docs/api/reference/#start-commercial
    def start_commercial(options = {})
      initialize_response nil, post('channels/commercial', options)
    end

    ## https://dev.twitch.tv/docs/api/reference/#get-channel-editors
    def get_channel_editors(options = {})
      initialize_response Editor, get('channels/editors', options)
    end

    ## https://dev.twitch.tv/docs/api/reference/#search-categories
    def search_categories(options = {})
      initialize_response Category, get('search/categories', options)
    end
  end
end
