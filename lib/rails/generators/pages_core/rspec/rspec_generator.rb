# encoding: utf-8

module PagesCore
  module Generators
    class RspecGenerator < Rails::Generators::Base
      desc "RSpec setup"
      source_root File.expand_path("../templates", __FILE__)

      def setup_gems
        gem_group :development do
          gem 'spring-commands-rspec'
          gem 'guard'
          gem 'guard-spring'
          gem 'guard-rspec'
        end
        gem_group :test, :development do
          gem 'rspec-rails'
          gem 'shoulda-matchers'
          gem 'json_spec'
          gem 'capybara'
          gem 'fuubar'
          gem 'timecop'
          gem 'factory_girl_rails'
        end
      end

      def setup_guard
        template 'Guardfile', File.join('Guardfile')
      end

      def setup_rspec
        create_file File.join('.rspec'), "--colour"
        create_file File.join("spec/controllers/.keep")
        create_file File.join("spec/factories/.keep")
        create_file File.join("spec/models/.keep")
        template 'spec_helper.rb', File.join('spec/spec_helper.rb')
        template 'factories.rb', File.join('spec/support/factories.rb')
        template 'mailer_macros.rb', File.join('spec/support/mailer_macros.rb')
      end
    end
  end
end