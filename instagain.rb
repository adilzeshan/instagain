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

  get '/signup' do
    @title = "Signup"
    erb :signup
  end

  post '/signup' do
    params[:]
    erb: signup
  end


end