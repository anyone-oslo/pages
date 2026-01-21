# frozen_string_literal: true

source "https://rubygems.org"

gem "rails", "~> 8.1.0"

# Pin connection_pool to 2.x until react-rails releases a version
# compatible with connection_pool 3.x
gem "connection_pool", "~> 2.4"

gemspec

group :development, :test do
  gem "pry"
  gem "pry-rescue"
  gem "pry-stack_explorer"

  gem "propshaft"

  gem "capybara"
  gem "factory_bot"
  gem "pg"
  gem "rails-controller-testing"
  gem "rspec_junit_formatter"
  gem "rspec-rails"
  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
  gem "selenium-webdriver"
  gem "semantic"
  gem "shoulda-matchers"
  gem "simplecov", "~> 0.17.1"
  gem "timecop"
end
