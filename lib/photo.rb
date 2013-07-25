class Photo
  include DataMapper::Resource
  include Paperclip::Resource

    property          :id,                    Serial
    belongs_to :user

    has_attached_file :photo,
                      #:path => "/:attachment/:id/:style/:basename.:extension",
                      # :path => "#{APP_ROOT}/public/images/:attachment/:id/:style/:basename.:extension",
                      # :styles => { :medium => "250x250>",
                      #            :thumb => "118x118>" }
                      :styles => { :medium => "800x800^",
                                 :thumb => "118x118^"
                                 },
                      :convert_options => {
                                            thumb: " -gravity center -crop '118x118+0+0'",
                                            medium: " -gravity center -crop '800x800+0+0'"
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
