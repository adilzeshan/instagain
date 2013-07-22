require 'data_mapper'
require './lib/user'

# begin
#   require 'jasmine'
#   #load 'jasmine/tasks/jasmine.rake'
# rescue LoadError
#   task :jasmine do
#     abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
#   end
# end

task :migrate do
  DataMapper.auto_migrate!
end

task :upgrade do
  DataMapper.auto_upgrade!
end
