require 'net/http'

class SullyHistoryJob
  include Sidekiq::Job

  sidekiq_options queue: 'history'

  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36"

  REQUEST_PARAMS = { 'user-agent' => USER_AGENT }

  def perform(user)
    uri = URI("https://sullygnome.com/api/tables/channeltables/streams/365/#{user}/%20/1/1/desc/0/100")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.path)
    response = http.request(request)

    raise "Failed to fetch posts: #{response.body}" unless response.code == '200'

    posts = JSON.parse(response.body)
    return posts
  rescue StandardError => e
    puts "Error: #{e.message}"
  end
end
