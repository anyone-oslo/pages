# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require "pages_core/version"

Gem::Specification.new do |s|
  s.name        = "pages_core"
  s.version     = PagesCore::VERSION
  s.authors     = ["Inge Jørgensen"]
  s.email       = ["inge@anyone.no"]
  s.homepage    = "https://github.com/anyone-oslo/pages"
  s.license     = "MIT"
  s.summary     = "Pages Core"
  s.description = "Pages Core"

  s.required_ruby_version = ">= 3.2.0"

  s.files = Dir[
    "{app,config,db,lib,vendor}/**/*",
    "spec/factories/**/*",
    "spec/support/fixtures/**/*",
    "Rakefile",
    "README.md",
    "template.rb"
  ]

  s.add_dependency "rails", ">= 6.0"

  s.add_dependency "actionpack-page_caching", ">= 1.1.0"
  s.add_dependency "alba"
  s.add_dependency "bcrypt"
  s.add_dependency "country_select", ">= 9.0.0"
  s.add_dependency "dis", "~> 2.2"
  s.add_dependency "dynamic_image", ">= 3.1.1"
  s.add_dependency "nokogiri"
  s.add_dependency "pastel"
  s.add_dependency "pg_search"
  s.add_dependency "premailer-rails"
  s.add_dependency "progress_bar"
  s.add_dependency "RedCloth", "~> 4.3"
  s.add_dependency "rotp", "~> 6.3"
  s.add_dependency "rqrcode"
  s.add_dependency "tty-table"
  s.add_dependency "typhoeus", "~> 1.4"
  s.add_dependency "will_paginate"

  # Locales
  s.add_dependency "rails-i18n", ">= 5.0.0"

  # Default asset dependencies
  s.add_dependency "jbuilder", "~> 2.5"

  # Extra asset dependencies
  s.add_dependency "tombolo"

  # ActiveRecord extensions
  s.add_dependency "acts_as_list", "~> 1.0"
  s.add_dependency "localizable_model", "~> 0.5"

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/anyone-oslo/pages/issues",
    "changelog_uri" => "https://github.com/anyone-oslo/pages/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/pages_core",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/anyone-oslo/pages"
  }
end
