require 'data_mapper'
require 'dm-paperclip'
require 'dm-validations'

require_relative   '../db/database'
require_relative   '../lib/user'
require_relative   '../lib/photo'

RSpec.configure do |config|
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/test.db")
  DataMapper.finalize
  DataMapper.auto_migrate!

  config.color = true
  config.formatter = :documentation
end