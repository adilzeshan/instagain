require 'digest'

class User
  attr :first,:last,:user_name,:email

    include DataMapper::Resource
    property :id,                     Serial
    property :first,                  String, :required => true
    property :last,                   String, :required => true
    property :user_name,              String, :required => true, :unique => true
    property :email,                  String, length: 255
    property :hashed_password,        String, length: 255


  def self.login(username, pwd)
    hashed = Digest::SHA256.hexdigest '**123SALTY**' + pwd

    first(user_name: username, hashed_password: hashed)
  end

  def password=(pwd)
    self.hashed_password = Digest::SHA256.hexdigest '**123SALTY**' + pwd
  end

  def get_first(username)
    first
  end

  def get_full_name
    first.capitalize+" "+last.capitalize
  end

  def change_name(full_name)
    self.first = full_name.split[0]
    self.last = full_name.split[1]
  end

    class Link

    include DataMapper::Resource

    storage_names[:default] = 'people_links'

    belongs_to :follower, 'User', :key => true
    belongs_to :followed, 'User', :key => true

  end

  has n, :links_to_followed_people, 'User::Link', :child_key => [:follower_id]
  has n, :links_to_followers, 'User::Link', :child_key => [:followed_id]

  has n, :followed_people, self, 
    :through => :links_to_followed_people, :via => :followed

  has n, :followers, self,
    :through => :links_to_followers, :via => :follower

  def follow(others)
    followed_people.concat(Array(others))
    save
    self
  end

  def unfollow(others)
    links_to_followed_people.all(:followed => Array(others)).destroy!
    reload
    self
  end
end