# vim:ft=ruby:ts=2:et:sw=2:sts=2
source "http://rubygems.org"

# Specify your gem's dependencies in lims-core.gemspec
gemspec

gem 'oj', :platforms => :mri
gem 'jrjackson', :platforms => :jruby

group :debugging do
  gem 'debugger', :platforms => :mri
  gem 'debugger-completion', :platforms => :mri
  gem 'ruby-debug', :platforms => :jruby
end

group :pry do
  gem 'debugger-pry', :require => 'debugger/pry', :platforms => :mri
end

group :autotest do
  gem 'autotest'
  gem 'autotest-growl'
  gem 'autotest-fsevent'
end

group :guard do
  gem "guard", '>= 1.3.0', :platforms => :mri
  gem "guard-rspec", :platforms => :mri
  gem "guard-bundler", :platforms => :mri
  gem "guard-yard", :platforms => :mri
  gem "terminal-notifier-guard", :platforms => :mri
  gem "rb-fsevent", '~> 0.9.1', :platforms => :mri
end

group :development do
  gem 'sqlite3', :platforms => :mri
  gem 'mysql2', :platforms => :mri
  gem 'ruby-prof', :platforms => :mri
  gem 'jdbc-sqlite3', :platforms => :jruby
  gem 'jdbc-mysql', :platforms => :jruby
end


group :yard do
  gem 'yard', '= 0.7.3', :platforms => :mri
  gem 'yard-rspec', '0.1', :platforms => :mri
  gem 'yard-state_machine', :platforms => :mri
  gem 'redcarpet', :platforms => :mri
  gem 'ruby-graphviz', :platforms => :mri
end

group :showoff do
  gem 'showoff', :platforms => :mri
end
