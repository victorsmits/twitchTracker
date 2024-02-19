# app/services/javascript_value_fetcher.rb
require 'httparty'

class JavascriptValueFetcher
  include HTTParty

  def initialize(channel_name)
    @url = "https://sullygnome.com/channel/#{channel_name}/10/streams"
  end

  def fetch_value(variable_name)
    headers = {
      'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'
    }
    response = self.class.get(@url, headers: headers)
    extract_js_value(response.body, variable_name) if response.success?
  end

  private

  def extract_js_value(js_content, variable_name)
    match = js_content.match(/\s+#{variable_name}\s+=\s+({.*?});/m)
    match[1] if match
  end
end
