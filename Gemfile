# vim:ft=ruby:ts=2:et:sw=2:sts=2
source "http://rubygems.org"

# Specify your gem's dependencies in lims-core.gemspec
gemspec

gem 'oj', :platforms => :mri

group :debugging do
  gem 'debugger'
  gem 'debugger-completion'
end

group :pry do
  gem 'debugger-pry', :require => 'debugger/pry'
end

group :autotest do
  gem 'autotest'
  gem 'autotest-growl'
  gem 'autotest-fsevent'
end

group :guard do
  gem "guard", '>= 1.3.0'
  gem "guard-rspec"
  gem "guard-bundler"
  gem "guard-yard"
  gem "terminal-notifier-guard"
  gem "rb-fsevent", '~> 0.9.1'
end

group :yard do
  gem 'yard', '= 0.7.3'
  gem 'yard-rspec', '0.1'
  gem 'yard-state_machine'
  gem 'redcarpet'
  gem 'ruby-graphviz'
end

group :showoff do
  gem 'showoff'
end
