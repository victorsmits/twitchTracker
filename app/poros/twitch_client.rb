require 'twitch_oauth2'

class TwitchClient

  def tokens
    @tokens = TwitchOAuth2::Tokens.new(
      client: {
        client_id: Figaro.env.twitch_client_id,
        client_secret: Figaro.env.twitch_client_secret,
      },
    )
  end

  def client
    @client = Twitch::Client.new(tokens: tokens)
  end

end
