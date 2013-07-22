
class Photo
	include DataMapper::Resource

    property :id,                     Serial
    property :name,				      String

   DataMapper.finalize
end

