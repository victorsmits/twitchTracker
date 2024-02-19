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
    url = "https://sullygnome.com/api/tables/channeltables/streams/365/#{id}/%20/1/1/desc/0/1"
    response = RestClient.get(url, REQUEST_PARAMS)
    data = JSON.parse(response.body)['data']
    user = process_user(data)
    process_streams(user,data)
  end

  private

  def process_user(data)
    user_name = data[0]['channelurl']
    temp_user = user(user_name)
    return temp_user if temp_user.present?
    User.create!(:twitch_name => user_name, :twitch_id => 89284114)
  end

  def process_streams(user,streams)
    streams.each do |data|
      unless stream_present? data["streamId"]
        Stream.create!(user:user, twitch_stream_id: data["streamId"])
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
