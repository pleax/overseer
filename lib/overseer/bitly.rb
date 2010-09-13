require 'httparty'

module Overseer::BitLy
  include HTTParty
  base_uri 'api.bit.ly'

  class << self
    def shorten(url)
      result = get("/v3/shorten", :query => {
        "login" => Overseer::CONFIG[:bitly_login],
        "apiKey" => Overseer::CONFIG[:bitly_api_key],
        "longUrl" => url
      })
      result["data"]["url"]
    rescue
      url
    end
  end
end

