class Photo
	include DataMapper::Resource
  include Paperclip::Resource

    property          :id,                    Serial
    belongs_to :user

    has_attached_file :photo,
                      :url => "/:attachment/:id/:style/:basename.:extension",
                      :path => "#{APP_ROOT}/public/images/:attachment/:id/:style/:basename.:extension",
                      :styles => { :medium => "250x250>",
                                 :thumb => "118x118>" }
end
