# frozen_string_literal: true

require 'faraday'
require 'faraday/parse_dates'
require 'faraday/retry'
require 'twitch_oauth2'


module Twitch
  # Core class for requests
  class Request
    # Base connection to Helix API.
    CONNECTION = Faraday.new(
      'https://api.twitch.tv/helix', {
      headers: { 'User-Agent': "twitch-tracker" }
    }
    ) do |faraday|
      faraday.request :retry,
                      exceptions: [*Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS, Faraday::ConnectionFailed]

      faraday.response :parse_dates

      faraday.request :json
      faraday.response :json
    end

    attr_reader :tokens

    # Initializes a Twitch client.
    #
    # - tokens [TwitchOAuth2::Tokens] Tokens object with their refreshing logic inside.
    # All client and authentication information (`client_id`, `:scopes`, etc.) stores there.
    def initialize(tokens:)
      @tokens = tokens

      CONNECTION.headers['Client-ID'] = self.tokens.client.client_id

      renew_authorization_header
    end

    %w[get post put patch].each do |http_method|
      define_method http_method do |resource, params|
        request http_method, resource, params
      end
    end

    def initialize_response(data_class, http_response)
      Response.new(data_class, http_response: http_response)
    end

    def renew_authorization_header
      CONNECTION.headers['Authorization'] = "Bearer #{tokens.access_token}"
    end

    def request(http_method, resource, params)
      http_response = CONNECTION.public_send http_method, resource, params

      if http_response.status == 401
        renew_authorization_header

        http_response = CONNECTION.public_send http_method, resource, params
      end

      return http_response if http_response.success?

      raise APIError.new(http_response.status, http_response.body)
    end
  end
end
