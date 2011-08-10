require 'twitter'

require 'overseer/bitly.rb'

require 'overseer/extractor.rb'

class Overseer::Bot

  def run
    @oauth = Twitter::OAuth.new(Overseer::CONFIG[:oauth_token], Overseer::CONFIG[:oauth_secret])
    unless Overseer::CONFIG.has_access_token?
      authenticate
    else
      authorize
    end
    @twitter = Twitter::Base.new(@oauth)
    @extractor = Overseer::Extractor::GosuGamersExtractor.new
    poll
  end

  private

  def authenticate
    request_token  = @oauth.request_token.token
    request_secret = @oauth.request_token.secret

    puts "[:] authorize bot on twitter with this url: #{@oauth.request_token.authorize_url}"

    puts "[:] what was the pin twitter provided you with?"
    print "> "
    pin = gets.chomp

    @oauth.authorize_from_request(request_token, request_secret, pin)

    puts "[:] add these values to config.rb:"
    puts ":access_token => #{@oauth.access_token.token.inspect},"
    puts ":access_secret => #{@oauth.access_token.secret.inspect},"
  end

  def authorize
    @oauth.authorize_from_access(Overseer::CONFIG[:access_token], Overseer::CONFIG[:access_secret])
  end

  def poll
    @extractor.fetch_new
    while true do
      begin
        @extractor.fetch_new.each do |replay|
          message = format_message(replay)
          @twitter.update(message)
          sleep Overseer::CONFIG[:post_interval]
        end
      rescue
        # pass
      rescue Timeout::Error
        # pass
      end
      sleep Overseer::CONFIG[:poll_interval]
    end
  end

  def format_message(replay)
    tokens = []

    tokens << replay.to_tweet

    url = replay.permalink
    url = Overseer::BitLy.shorten(url) if Overseer::CONFIG.has_bitly_credentials?
    tokens << url

    hash_tags = []
    hash_tags += replay.hash_tags
    hash_tags += Overseer::CONFIG[:hash_tags] if Overseer::CONFIG.has_hash_tags?

    unless hash_tags.empty?
      hash_tags = hash_tags.map { |t| "\##{t}" }.join(' ')
      tokens << hash_tags
    end

    tokens.join(' ')
  end

end

