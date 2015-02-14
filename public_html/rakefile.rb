require './db/environment'

namespace :db do
  desc "Migrate the database"
  task :migrate do
    ActiveRecord::Migrator.migrate('./site/Model/Migration', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end
end