# frozen_string_literal: true

source "https://rubygems.org"

gem "rails", "~> 6.1.0"
gem "rspec-rails", "~> 4.0.0.beta3"

gemspec

# Ruby 3.1 compatibility, remove when mail gem is updated
gem "net-imap", require: false
gem "net-pop", require: false
gem "net-smtp", require: false

group :development, :test do
  gem "pry"
  gem "pry-rescue"
  gem "pry-stack_explorer"

  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end
