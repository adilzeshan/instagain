require 'sinatra'
require 'json'
require_relative 'db/database.rb'
require_relative 'lib/user.rb'
require_relative 'lib/photo.rb'
DataMapper.finalize


class Instagain <Sinatra::Base
  enable :session
  set :session_secret, 'random-key'
  use Rack::Session::Cookie

  def login?
    if session[:user_name].nil?
      return false
    else
      return true
    end
  end

  helpers do
    def get_db_user
      User.first(user_name: session[:user_name])
    end
  end

  get '/reset' do
    session.clear
    redirect '/'
  end

  get '/' do
    @title = "Instagain"
    @logged_in = login?
    if @logged_in != false
      @name = session[:user].get_full_name
    end
    erb :home
  end

  get '/signup' do
    @title = "Signup"
    erb :signup
  end

  post '/signup' do
    @user = User.create({
                            first: params[:first_name],
                            last: params[:last_name],
                            user_name: params[:user_name],
                            email: params[:email_address],
                            password: params[:password]
                          })
      redirect '/signin'
  end

  get '/signin' do
    @title = 'Sign In'
    erb :signin
  end

  post '/signin' do
    @user = User.login(params[:user_name], params[:password])
    if @user
      session[:user] = @user
      session[:user_name] = params[:user_name]
      redirect "/"
    else
      erb :error
    end
  end

  post '/profile' do
    @user = User.update({
      first: params[:first_name],
      last: params[:last_name],
      email: params[:email_address]
      })
    redirect '/profile'
  end

  get '/profile' do
    @first =  get_db_user.first
    @last = get_db_user.last
    @usernm = session[:user_name]
    @email = get_db_user.email
    erb :profile
  end

  # post '/profile_data' do
  #   # content_type :json
  #   # {
  #   #   full_name: "Adil Zeshan"
  #   #   }.to_json
  #   @user = User.update({
  #     first: params[:first_name],
  #     last: params[:last_name],
  #     user_name: params[:user_name],
  #     email: params[:email_address]
  #     })

  # end

end