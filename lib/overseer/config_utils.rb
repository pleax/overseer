
module Overseer::ConfigUtils
  def has_access_token?
    not self[:access_token].nil? and not self[:access_secret].nil?
  end

  def has_bitly_credentials?
    not self[:bitly_login].nil? and not self[:bitly_api_key].nil?
  end
end

