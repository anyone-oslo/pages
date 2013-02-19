# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pages_core/version"

Gem::Specification.new do |s|
  s.name        = "pages_core"
  s.version     = PagesCore::VERSION
  s.authors     = ["Inge Jørgensen"]
  s.email       = ["inge@manualdesign.no"]
  s.homepage    = ""
  s.summary     = %q{Pages Core}
  s.description = %q{Pages Core}

  s.rubyforge_project = "."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rake", "0.9.2.2"
  s.add_dependency "rails", "3.2.8"
  #s.add_dependency "rdoc", "3.12"

  s.add_dependency "bcrypt-ruby"
  s.add_dependency 'capistrano'
  s.add_dependency 'vector2d'
  s.add_dependency 'RedCloth', '4.2.9'
  s.add_dependency 'daemon-spawn', '0.2.0'
  s.add_dependency 'pages_console'
  s.add_dependency 'ruby-openid'
  s.add_dependency 'httparty', '0.6.1' # For Campfire


  s.add_dependency 'rmagick', '2.12.2'
  s.add_dependency 'dynamic_image-pages', ">= 0.0.11"
  #gem 'dynamic_image-pages', :require => 'dynamic_image', :path => '~/Dev/gems/dynamic_image-pages'

  # Assets
  s.add_dependency 'sass-rails'
  s.add_dependency 'json', '1.5.1'
  s.add_dependency 'coffee-script', '2.1.3'

  # ActiveRecord extensions
  s.add_dependency 'acts_as_list', '0.1.4'
  s.add_dependency 'acts_as_tree', '0.2.0'

  # reCAPTCHA
  s.add_dependency "recaptcha", '0.3.4'

  # Delayed Job
  s.add_dependency 'delayed_job', '3.0.5'
  s.add_dependency 'delayed_job_active_record', '0.3.3'
  s.add_dependency 'daemons', '1.1.0'

  # Thinking Sphinx
  s.add_dependency 'thinking-sphinx', '2.0.14'
  s.add_dependency 'ts-delayed-delta', '1.1.3'

  s.add_dependency 'term-ansicolor'


  # Development
  s.add_development_dependency "mysql"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency 'factory_girl', '2.6.4'
  s.add_development_dependency 'factory_girl_rails', '1.7.0'
  s.add_development_dependency 'combustion', '~> 0.3.2'
  s.add_development_dependency "sdoc", ">= 0.3.0"

end
