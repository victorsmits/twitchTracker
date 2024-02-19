require 'net/http'
require 'rest-client'

class SullyHistoryJob
  include Sidekiq::Job

  sidekiq_options queue: 'history'

  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36"

  REQUEST_PARAMS = { 'user-agent' => USER_AGENT }

  def perform(user)
    id = sully_streamer_id user
    return unless id
    streams = get_all_streams id
    user = process_user(user, id)
    process_streams(user, streams)
  end

  private

  def get_streams(channel_id, duration = 365, page_number = 0, page_size = 100)
    url = "https://sullygnome.com/api/tables/channeltables/streams/#{duration}/#{channel_id}/%20/#{page_number}/1/desc/#{page_number * page_size}/#{page_size}"
    response = RestClient.get(url, REQUEST_PARAMS)
    JSON.parse(response.body)['data']
  end

  def get_all_streams(channel_id)
    all_streams = []
    page_number= 0
    loop do
      data = get_streams(channel_id, 365, page_number, 100)
      break if data.empty?

      all_streams.concat(data)

      page_number += 1
    end
    all_streams
  end

  def process_user(user_name, id)
    temp_user = user(user_name)
    return temp_user if temp_user.present?
    User.create!(twitch_name: user_name, twitch_id: 89284114, sully_streamer_id: id)
  end

  def process_streams(user, streams)
    streams.each do |data|
      unless stream_present? data["streamId"]
        Stream.create!(
          user: user,
          twitch_stream_id: data["streamId"],
          max_viewer_count: data["maxviewers"],
          started_at: data["starttime"],
          ended_at: data["endtime"]
        )
      end
    end
  end

  def user(twitch_name)
    User.find_by(twitch_name: twitch_name)
  end

  def stream_present?(stream_id)
    Stream.find_by(twitch_stream_id: stream_id).present?
  end

  def sully_streamer_id(user)
    fetcher = JavascriptValueFetcher.new(user)
    raw_page_info = fetcher.fetch_value('PageInfo')
    return unless raw_page_info
    page_info = JSON.parse(raw_page_info)
    page_info['id'] if page_info
  end

end
