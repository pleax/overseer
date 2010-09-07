require 'boot.rb'

require 'httparty'

module BitLy
  include HTTParty
  base_uri 'api.bit.ly'

  class << self
    def shorten(url)
      result = get("/v3/shorten", :query => {
        "login" => CONFIG[:bitly_login],
        "apiKey" => CONFIG[:bitly_api_key],
        "longUrl" => url
      })
      result["data"]["url"]
    rescue
      url
    end
  end
end

# puts BitLy.shorten("http://example.com")
