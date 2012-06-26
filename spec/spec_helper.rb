require 'rubygems'
require 'bundler'

Bundler.require :default, :development

#require 'capybara/rspec'

Combustion.initialize! :active_record, :action_controller, :action_view, :action_mailer

require 'rspec/rails'
#require 'capybara/rails'

RSpec.configure do |config|
  #config.use_transactional_fixtures = true
end