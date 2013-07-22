require 'sinatra'
require_relative 'db/database.rb'
require_relative 'lib/user.rb'
require_relative 'lib/photo.rb'
DataMapper.finalize

class Instagain <Sinatra::Base
  enable :session
  use Rack::Session::Cookie

  get '/' do
    @title = "Instagain"
    erb :home
  end

end