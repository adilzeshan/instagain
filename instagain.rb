require 'sinatra'
require 'json'
require 'dm-core'
require 'dm-paperclip'
require 'dm-validations'
require 'aws/s3'

APP_ROOT = File.expand_path(File.dirname(__FILE__))

require_relative 'db/database.rb'
require_relative 'lib/user.rb'
require_relative 'lib/photo.rb'

DataMapper.finalize

class Instagain <Sinatra::Base
  enable :session
  set :session_secret, 'random-key'
  use Rack::Session::Cookie

  helpers do
    def login?
      if session[:user_name].nil?
        return false
      else
        return true
      end
    end

    def h(text)
      Rack::Utils.escape_html(text)
    end

    def current_user
      User.first(user_name: session[:user_name])
    end

    def get_following_users_photos
      @photos =[]
      current_user.get_all_following_users.each do |user|
        @photos << user.photos(:order => [:photo_updated_at.desc])
      end
      if @photos.length > 0
        @photos.flatten!.shuffle!
      end
      @photos
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
    @name = current_user.get_full_name if current_user
    @photos = Photo.all(:order => [ :photo_file_name.desc ]).shuffle || []
    erb :home
  end

  get '/signup' do
    @title = "Signup"
    erb :signup
  end

  post '/signup' do
    first_name_input = params[:first_name]
    last_name_input = params[:last_name]
    user_name_input = params[:user_name]
    email_input = params[:email_address]
    password_input = params[:password]

    if first_name_input.length < 4
      return "Your first name is too short. Sorry."
    end

    if last_name_input.length < 4
      return "your last name is too short. Sorry."
    end

    if user_name_input.length < 5
      return "Your username is too short."
    end

    if !email_input.include?('@') || !email_input.include?('.')
      return "Your email doesn't look normal..."
    end

    if password_input.length < 6
      return "You need a longer password."
    end

    @user = User.create({
                          first: first_name_input,
                          last: last_name_input,
                          user_name: user_name_input,
                          email: email_input,
                          password: password_input
                        })

    content_type :json
    return {success: true}.to_json if @user
  end

  get '/users' do
    @userArray = get_all_user_names
    @userArray.delete(current_user.user_name)
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
    @user = current_user
    @user.update({
                   first: params[:first_name],
                   last: params[:last_name],
                   email: params[:email_address]
    })
    redirect '/profile'
  end

  get '/profile' do
    @title = "Profile"
    @logged_in = login?
    @name = current_user.get_full_name if current_user
    @first =  current_user.first
    @last = current_user.last
    @usernm = session[:user_name]
    @email = current_user.email
    @myphotos = current_user.photos(:order => [:photo_updated_at.desc])
    @followingphotos = get_following_users_photos
    @following = current_user.get_all_following_user_names
    @followed = current_user.get_all_followed_user_names
    @not_following = current_user.get_all_not_following_user_names
    erb :profile
  end

  get '/profile/:user' do
    @other_user_name = params[:user]
    @other_user = User.get_other_user(@other_user_name)
    redirect '/profile' if @other_user_name == current_user.user_name
    @logged_in = login?
    @name = current_user.get_full_name if current_user
    @their_photos =@other_user.photos(:order => [:photo_updated_at.desc])
    @following = @other_user.get_all_following_user_names
    @followed = @other_user.get_all_followed_user_names
    @not_following = @other_user.get_all_not_following_user_names
    erb :other_profile
  end

  get '/upload' do
    @title = "Instagain"
    @logged_in = login?
    @name = current_user.get_full_name if current_user
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
    @me = current_user
    if @followuser
      @me.follow(@followuser)
    else
      "Couldn't find user #{params[:user]}"
    end
    redirect '/profile'
  end

  get '/unfollow/:user' do
    @followuser = User.first(user_name: params[:user])
    @me = current_user
    if @followuser
      @me.unfollow(@followuser)
    else
      "Couldn't find user #{params[:user]}"
    end
    redirect '/profile'
  end

  get '/delete/:photo' do
    @photo = Photo.first(id: params[:photo])
    if @photo && @photo.user == current_user
      @photo.destroy()
    else
      "Photo #{params[:photo]} does not exist"
    end
    redirect '/profile'
  end

end
