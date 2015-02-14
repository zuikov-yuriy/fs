require 'fiber_pool'
require 'active_record'
require 'active_record/connection_adapters/abstract_adapter'
require 'fiber'
require 'yaml'


db = YAML::load(File.open(File.join(File.dirname(__FILE__), 'database.yml')))

ActiveRecord::Base.logger = Logger.new(STDERR)
#ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
#ActiveRecord::Base.clear_active_connections!


ActiveRecord::Base.establish_connection(db)
