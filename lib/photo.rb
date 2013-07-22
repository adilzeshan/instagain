
class Photo
	include DataMapper::Resource

    property :id,                     Serial
    property :name,				      String
    property :url,				  String


	def change_name(new_name)
	  self.name = new_name
	end

end