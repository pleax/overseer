require 'rubygems'
require 'bundler/setup'

require 'config.rb'

module ConfigUtils
  def has_bitly_credentials?
    not self[:bitly_login].nil? and not self[:bitly_api_key].nil?
  end
end

CONFIG.extend(ConfigUtils)
