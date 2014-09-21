# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'spork'

Spork.prefork do

  ENV["RAILS_ENV"] = 'test'

  require 'combustion'
  require 'capybara/rspec'

  Combustion.initialize! :all

  require 'capybara/rails'
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'thinking_sphinx/test'

  Delayed::Worker.backend = :active_record
  FactoryGirl.find_definitions

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Use FactoryGirl shorthand
    config.include FactoryGirl::Syntax::Methods

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    config.before(:suite) do
      # Ensure sphinx directories exist for the test environment
      ThinkingSphinx::Test.init
      # Configure and start Sphinx, and automatically
      # stop Sphinx at the end of the test suite.
      ThinkingSphinx::Test.start_with_autostop
    end

    # Clean the Shrouded storage after each example
    config.after(:each) do
      storage_root = Rails.root.join('db', 'shrouded', 'test')
      FileUtils.rm_rf(storage_root) if File.exists?(storage_root)
    end
  end
end

Spork.each_run do
  FactoryGirl.reload
  PagesCore.load_dependencies!

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| load f}

  RSpec.configure do |config|
    # Macros
    #config.include LoginMacros, :type => :controller
  end

end
