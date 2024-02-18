require 'net/http'
require 'rest-client'

class SullyHistoryJob
  include Sidekiq::Job

  sidekiq_options queue: 'history'

  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36"

  REQUEST_PARAMS = { 'user-agent' => USER_AGENT }

  def perform(user)
    url = "https://sullygnome.com/api/tables/channeltables/streams/365/#{user}/%20/1/1/desc/0/100"
    response = RestClient.get(url, REQUEST_PARAMS)
    p response.code
    p response.body
  end
end
