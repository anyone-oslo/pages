require File.dirname(__FILE__) + '/config/environment' if !defined?(Rails) || !Rails.initialized?
require 'sprockets'

unless Rails.env.production?
  map '/assets' do
    sprockets = Sprockets.env
    run sprockets
  end
end

map '/' do
  run ActionController::Dispatcher.new
end