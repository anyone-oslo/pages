require 'rubygems'

require 'spork'

Spork.prefork do

  Bundler.require :default, :development

  Spork.trap_method(Rails::Application, :eager_load!)

  Combustion.initialize!
  FactoryGirl.find_definitions

  require 'rspec/rails'
  require 'rspec/autorun'

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
