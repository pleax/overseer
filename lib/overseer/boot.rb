require 'rubygems'
require 'bundler/setup'

require 'config.rb'

require 'overseer/config_utils.rb'

Overseer::CONFIG.extend(Overseer::ConfigUtils)
