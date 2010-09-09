require 'boot.rb'

require 'twitter'

require 'gg.rb'
require 'bitly.rb'

oauth = Twitter::OAuth.new(CONFIG[:oauth_token], CONFIG[:oauth_secret])

unless CONFIG.has_access_token?
  request_token  = oauth.request_token.token
  request_secret = oauth.request_token.secret

  puts "[:] authorize bot on twitter with this url: #{oauth.request_token.authorize_url}"

  puts "[:] what was the pin twitter provided you with?"
  print "> "
  pin = gets.chomp

  oauth.authorize_from_request(request_token, request_secret, pin)

  puts "[:] add these values to config.rb:"
  puts ":access_token => #{oauth.access_token.token.inspect},"
  puts ":access_secret => #{oauth.access_token.secret.inspect},"
else
  oauth.authorize_from_access(CONFIG[:access_token], CONFIG[:access_secret])
end

twitter = Twitter::Base.new(oauth)

#twitter.update("He's alive!!")

extractor = GosuGamersExtractor.new

while true do
  begin
    extractor.fetch_new.each do |replay|
      url = replay.permalink
      url = BitLy.shorten(url) if CONFIG.has_bitly_credentials?
      twitter.update("#{replay.to_tweet} #{url}")
      sleep CONFIG[:post_interval]
    end
  rescue
  end
  sleep CONFIG[:poll_interval]
end

