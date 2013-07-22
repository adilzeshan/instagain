require 'digest'

class User

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

  def get_full_name
    first.capitalize+" "+last.capitalize
  end

  def change_name(full_name)
    self.first = full_name.split[0]
    self.last = full_name.split[1]
  end
end