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

    def get_other_user(username)
      User.first(user_name: username)
    end

    def get_all_user_names
      #User.all.map(&:user_name)
      User.all.map {|user| user.user_name }
    end

    def get_all_users
      #User.all.map(&:user_name)
      User.all.map {|user| user }
    end

    def get_all_following_users
      @me = get_db_user
      @me.followed_users.map {|user| user }
    end
    def get_all_following_user_names(me = get_db_user())
      @me = me
      @me.followed_users.map {|user| user.user_name }
    end

    def get_all_followed_users
      @me = get_db_user
      @me.followers.map {|user| user }
    end

    def get_all_followed_user_names(me = get_db_user())
      @me = me
      @me.followers.map {|user| user.user_name }
    end

    def get_all_not_following_users
      @me = get_db_user
      get_all_users - get_all_following_users
    end

        def get_all_not_following_user_names(me = get_db_user())
      @me = me
      get_all_user_names - get_all_following_user_names - [@me.user_name]

    end

    def get_user_photos(user)
        Photo.all(user_id: user.id,:order => [ :photo_updated_at.desc ]     )
    end

    def get_following_users_photos
      @photos =[]
      get_all_following_users.each do |user|
          @photos << Photo.all(user_id: user.id, :order => [ :photo_updated_at.desc ]  )
      end
      @photos
    end

    def get_all_photos
        Photo.all(:order => [ :photo_file_name.desc ]  )
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
      @name = get_db_user.get_full_name
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
    @userArray.delete(get_db_user.user_name)
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
      @name = get_db_user.get_full_name
    end
    @first =  get_db_user.first
    @last = get_db_user.last
    @usernm = session[:user_name]
    @email = get_db_user.email
    @myphotos = get_user_photos(session[:user])
    @followingphotos = get_following_users_photos
    #puts get_all_following_users
    @following = get_all_following_user_names
    @followed = get_all_followed_user_names
    @not_following = get_all_not_following_user_names
    erb :profile
  end

  get '/profile/:user' do
    @other_user_name = params[:user]
    if @other_user_name == get_db_user.user_name
      redirect '/profile'
    end

    @title = "#{@other_user_name}'s profile"
    @logged_in = login?
    if @logged_in != false
      @name = session[:user].get_full_name
    end
    # @first =  User.first(user_name: @other_user_name)
    # @last = User.last(user_name: @other_user_name)
    # @email = User.email(user_name: @other_user_name)
    @their_photos = get_user_photos(get_other_user(@other_user_name))
    @following = get_all_following_user_names(get_other_user(@other_user_name))
    @followed = get_all_followed_user_names(get_other_user(@other_user_name))
    @not_following = get_all_not_following_user_names(get_other_user(@other_user_name))

    erb :other_profile
  end

  get '/upload' do
    @title = "Instagain"
    @logged_in = login?
    if @logged_in != false
      @name = get_db_user.get_full_name
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

  get '/unfollow/:user' do
    @followuser = User.first(user_name: params[:user])
    @me = get_db_user
    if @followuser
      @me.unfollow(@followuser)
    else
      "Couldn't find user #{params[:user]}"
    end
    redirect '/profile'
  end

  get '/delete/:photo' do
    @photo = Photo.first(id: params[:photo])
    puts @photo.inspect
    if @photo
      @photo.destroy()
    else
      "Photo #{params[:photo]} does not exist"
    end
    redirect '/profile'
  end

end