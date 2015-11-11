require "bundler/gem_tasks"
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

namespace :db do

  task :mysqltest do
    `echo "DROP DATABASE  IF EXISTS test_lims_core;" | mysql -u root`
    `echo "CREATE DATABASE test_lims_core;" | mysql -u root`
  end

end



