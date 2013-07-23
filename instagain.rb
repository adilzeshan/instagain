require 'sinatra'
require 'json'
require 'dm-paperclip'

APP_ROOT = File.expand_path(File.dirname(__FILE__))

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

    def get_all_user_names
      #User.all.map(&:user_name)
      User.all.map {|user| user.user_name }
    end

    def get_user_photos(user)
        Photo.all(user_id: user.id)
    end

    def get_all_photos
        Photo.all
    end

    def make_paperclip_mash(file_hash)
      mash = Mash.new
      mash['tempfile'] = file_hash[:tempfile]
      mash['filename'] = file_hash[:filename]
      mash['content_type'] = file_hash[:type]
      mash['size'] = file_hash[:tempfile].size
      mash
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
    @photos = get_all_photos
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

  get '/users' do
    @userArray = get_all_user_names
    content_type :json
      {
        allusers: @userArray
      }.to_json
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
    @title = "Profile"
    @logged_in = login?
    if @logged_in != false
      @name = session[:user].get_full_name
    end
    @first =  get_db_user.first
    @last = get_db_user.last
    @usernm = session[:user_name]
    @email = get_db_user.email
    @photos = get_user_photos(session[:user])
    erb :profile
  end

  get '/upload' do
    @title = "Instagain"
    @logged_in = login?
    if @logged_in != false
      @name = session[:user].get_full_name
    end
    erb :upload
  end

  post '/upload' do
    halt 409, "File seems to be emtpy" unless params[:photo][:tempfile].size > 0
    @photo = Photo.new(
            :photo => make_paperclip_mash(params[:photo]),
            :user_id => session[:user].id
            )
    @photo.save
    halt 409, "There were some errors processing your request...\n#{@photo.errors.inspect}" unless @photo.save
    redirect '/profile'
  end

  get '/follow/:user' do
    @followuser = User.first(user_name: params[:user])
    @me = get_db_user
    if @followuser
      @me.follow(@followuser)
    else
      "Couldn't find user #{params[:user]}"
    end
    redirect '/profile'
  end

end