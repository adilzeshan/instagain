
class User

    include DataMapper::Resource
    property :id,                     Serial
    property :first,                  String, :required => true
    property :last,                   String, :required => true
    property :user_name,              String, :required => true, :unique => true

    DataMapper.finalize

  def get_full_name
    first+" "+last
  end

  def change_name(full_name)
    self.first = full_name.split[0]
    self.last = full_name.split[1]
  end



end