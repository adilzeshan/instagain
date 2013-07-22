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





  get '/login' do
    @title = 'Login'
    erb :login
  end

  post '/login' do
    @user = User.login params[:user_name], params[:password]
    if @user
      erb :success, locals: { action: 'Logged in' }
    else
      erb :error
    end
  end




end