# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require "pages_core/version"

Gem::Specification.new do |s|
  s.name        = "pages_core"
  s.version     = PagesCore::VERSION
  s.authors     = ["Inge Jørgensen"]
  s.email       = ["inge@anyone.no"]
  s.homepage    = ""
  s.summary     = "Pages Core"
  s.description = "Pages Core"

  s.required_ruby_version = ">= 2.7.0"

  s.files = Dir[
    "{app,config,db,lib,vendor}/**/*",
    "Rakefile",
    "README.md",
    "template.rb"
  ]

  s.add_development_dependency "capybara", "~> 3.32"
  s.add_development_dependency "factory_bot", "~> 4.11.0"
  s.add_development_dependency "pg", "~> 1.2.3"
  s.add_development_dependency "rails-controller-testing", "~> 1.0.0"
  s.add_development_dependency "rspec_junit_formatter"
  s.add_development_dependency "rspec-rails", ">= 3.8.1"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "simplecov", "~> 0.17.1"
  s.add_development_dependency "timecop", "~> 0.8.0"

  s.add_dependency "rails", ">= 6.0"

  s.add_dependency "actionpack-page_caching", ">= 1.1.0"
  s.add_dependency "active_model_serializers", "~> 0.10.12"
  s.add_dependency "bcrypt"
  s.add_dependency "country_select"
  s.add_dependency "dis", "~> 1.1.2"
  s.add_dependency "dynamic_image", ">= 2.0"
  s.add_dependency "lograge", "~> 0.11.2"
  s.add_dependency "nokogiri"
  s.add_dependency "pg_search"
  s.add_dependency "progress_bar"
  s.add_dependency "rails-healthcheck", "~> 1.0.3"
  s.add_dependency "RedCloth", "~> 4.3.2"
  s.add_dependency "typhoeus", "~> 1.4.0"
  s.add_dependency "will_paginate"

  # Locales
  s.add_dependency "rails-i18n", ">= 5.0.0"

  # Default asset dependencies
  s.add_dependency "coffee-rails", "~> 4.2"
  s.add_dependency "jbuilder", "~> 2.5"
  s.add_dependency "jquery-rails"
  s.add_dependency "sass-rails", ">= 5.0"
  s.add_dependency "uglifier", ">= 1.3.0"

  # Extra asset dependencies
  s.add_dependency "font-awesome-rails", "~> 4.7"
  s.add_dependency "jquery-ui-rails", "~> 6.0.0"
  s.add_dependency "react-rails", "~> 2.4"

  # ActiveRecord extensions
  s.add_dependency "acts_as_list", "~> 0.9"
  s.add_dependency "localizable_model", ">= 0.5.3"

  # Delayed Job
  s.add_dependency "daemons", "~> 1.2.0"
  s.add_dependency "delayed_job", "~> 4.1.2"
  s.add_dependency "delayed_job_active_record", "~> 4.1.1"
end
