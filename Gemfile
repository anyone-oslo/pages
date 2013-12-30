source "http://rubygems.org"
source "http://gems.manualdesign.no"

gem 'mysql2'

gemspec

# Workaround until jcrop-rails is updated
gem 'jcrop-rails', git: 'git@github.com:westonplatter/jcrop-rails.git', branch: 'master'

group :development do
  gem 'combustion'
  gem 'sdoc'
  gem 'rb-fsevent'
  gem 'ruby_gntp'
  gem 'guard'
  gem 'guard-spork'
  gem 'guard-rspec'
end

group :test, :development do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'fuubar'
  gem 'factory_girl'
  gem 'spork'
end
