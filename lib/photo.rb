class Photo
  include DataMapper::Resource
  include Paperclip::Resource

    property          :id,                    Serial

    belongs_to         :user
    has_attached_file :photo,

                      :styles => {  :big => "800x",
                                    :medium => "400x400^",
                                    :thumb => "118x118^"
                                 },
                      :convert_options => {
                                            thumb: " -gravity center -crop '118x118+0+0'",
                                            medium: " -gravity center -crop '400x400+0+0'"
                                          },
                    :storage          => :s3,
                    :s3_credentials   => {
                      :access_key_id      => 'AKIAJOKTYMMDVLS3DDMQ',
                      :secret_access_key  => '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',
                      :bucket             => 'instagain2'
                    },
                    :path => ":attachment/:id/:style/:basename.:extension",
                    :url => "/:attachment/:id/:style/:basename.:extension"


end
