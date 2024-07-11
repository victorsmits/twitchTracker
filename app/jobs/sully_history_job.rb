require 'net/http'
require 'rest-client'

class SullyHistoryJob
  include Sidekiq::Job

  sidekiq_options queue: 'history'

  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36"

  REQUEST_PARAMS = { 'user-agent' => USER_AGENT }

  def perform(user_name)
    id = sully_streamer_id user_name
    return unless id
    @streams = get_all_streams id
    @twitch_user = twitch_client.get_users({ login: user_name }).data.first
    @user = process_user(user_name, id)
    process_streams
    process_videos twitch_user.videos
  end

  private

  attr_reader :user, :streams, :twitch_user

  def twitch_client
    @twitch_client = TwitchClient.new.client
  end

  def get_streams(channel_id, duration = 365, page_number = 0, page_size = 100)
    url = "https://sullygnome.com/api/tables/channeltables/streams/#{duration}/#{channel_id}/%20/#{page_number}/1/desc/#{page_number * page_size}/#{page_size}"
    response = RestClient.get(url, REQUEST_PARAMS)
    JSON.parse(response.body)['data']
  end

  def get_all_streams(channel_id)
    all_streams = []
    page_number = 0
    loop do
      data = get_streams(channel_id, 365, page_number, 100)
      break if data.empty?

      all_streams.concat(data)

      page_number += 1
    end
    all_streams
  end

  def process_user(user_name, id)
    User.find_or_create_by!(twitch_name: user_name, twitch_id: twitch_user.id, sully_streamer_id: id)
  end

  def process_game(name)
    game = twitch_client.get_games({ name: name }).data
    Game.find_or_create_by!({ twitch_id: game.first&.id.to_i, name: name }) unless game.first.nil?
  end

  def process_streams
    streams.each do |data|
      stream = Stream.find_or_create_by!(
        user: user,
        twitch_stream_id: data["streamId"].to_i,
        max_viewer_count: data["maxviewers"].to_i,
        started_at: data["starttime"],
        ended_at: data["endtime"]
      )
      games = process_played_games data["gamesplayed"]
      games.each do |game|
        StreamLog.find_or_create_by!({
                                       stream: stream,
                                       game: game
                                     })
      end

    end
  end

  def process_played_games(gamesplayed)
    games = gamesplayed.split('|').each_slice(3).to_a
    games.map do |game|
      process_game game[0]
    end
  end

  def sully_streamer_id(user)
    fetcher = JavascriptValueFetcher.new(user)
    raw_page_info = fetcher.fetch_value('PageInfo')
    return unless raw_page_info
    page_info = JSON.parse(raw_page_info)
    page_info['id'] if page_info
  end

  def process_videos(videos)
    videos.each do |video|
      StreamVideo.find_or_create_by!({
                                       user: user,
                                       stream_id: video.stream_id,
                                       vod_id: video.id,
                                       title: video.title,
                                       published_at: video.published_at,
                                       thumbnail_url: video.thumbnail_url,
                                       duration: video.duration,
                                       view_count: video.view_count,
                                     })
    end
  end
end
