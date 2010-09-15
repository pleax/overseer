
module Overseer::ConfigUtils
  def has_access_token?
    not self[:access_token].nil? and not self[:access_secret].nil?
  end

  def has_bitly_credentials?
    not self[:bitly_login].nil? and not self[:bitly_api_key].nil?
  end

  def has_hash_tags?
    not self[:hash_tags].nil? and not self[:hash_tags].empty?
  end
end

