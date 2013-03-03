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

  s.add_dependency "rake", "~> 0.9.2"
  s.add_dependency "rails", "~> 3.2.11"

  s.add_dependency 'bcrypt-ruby'
  s.add_dependency 'RedCloth', '~> 4.2.9'
  s.add_dependency 'daemon-spawn', '~> 0.2.0'
  s.add_dependency 'pages_console', '~> 0.4.13'
  s.add_dependency 'ruby-openid', '~> 2.2.3'
  s.add_dependency 'vector2d'
  s.add_dependency 'dynamic_image-pages', '>= 0.0.13'

  # Assets
  s.add_dependency 'sass-rails'
  s.add_dependency 'json'
  s.add_dependency 'coffee-script'
  s.add_dependency 'jquery-rails', '2.1.4'    # Version locked, upgrade to newest when jcrop-rails is updated
  s.add_dependency 'jquery-ui-rails', '3.0.1' # Version locked, upgrade to newest when jcrop-rails is updated
  s.add_dependency 'jquery-cookie-rails'
  s.add_dependency 'jcrop-rails'
  s.add_dependency 'underscore-rails'

  # ActiveRecord extensions
  s.add_dependency 'acts_as_list'
  s.add_dependency 'acts_as_tree', '~> 0.2.0' # This is the latest version with Ruby 1.8 support

  # reCAPTCHA
  s.add_dependency 'recaptcha', '~> 0.3.4'

  # Delayed Job
  s.add_dependency 'delayed_job', '~> 3.0.5'
  s.add_dependency 'delayed_job_active_record', '~> 0.3.3'
  s.add_dependency 'daemons', '1.1.0'

  # Thinking Sphinx
  s.add_dependency 'thinking-sphinx', '~> 2.0.14' # 3.0 has a new API
  s.add_dependency 'ts-delayed-delta', '1.1.3'

  # Deployment
  s.add_dependency 'capistrano'
  s.add_dependency 'term-ansicolor'
  s.add_dependency 'httparty', '~> 0.10.2' # For Campfire
end
