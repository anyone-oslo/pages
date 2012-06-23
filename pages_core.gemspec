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

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"

  s.add_dependency "rake", "0.9.2.2"
  s.add_dependency "rails", "3.0.3"
  s.add_dependency "rdoc", "3.12"

  s.add_dependency "bcrypt-ruby"
  s.add_dependency 'capistrano'
  s.add_dependency 'capistrano_colors'
  s.add_dependency 'vector2d'
  s.add_dependency 'enumerable_mapper'
  s.add_dependency 'hpricot', '0.8.6'
  s.add_dependency 'simple-rss', '1.2.3'
  s.add_dependency 'RedCloth', '4.2.9'
  s.add_dependency 'unicode', '0.3.1'
  s.add_dependency 'daemon-spawn', '0.2.0'
  s.add_dependency 'pages_console'
  s.add_dependency 'ruby-openid'
  s.add_dependency 'httparty', '0.6.1'
  s.add_dependency 'delayed_job', '3.0.3'

  s.add_dependency 'rmagick', '2.12.2'
  s.add_dependency 'dynamic_image-pages'
  #gem 'dynamic_image-pages', :require => 'dynamic_image', :path => '~/Dev/gems/dynamic_image-pages'

  # Assets
  s.add_dependency 'sass', '3.1.19'
  s.add_dependency 'json', '1.5.1'
  s.add_dependency 'coffee-script', '2.1.3'

  # ActiveRecord extensions
  s.add_dependency 'acts_as_list', '0.1.4'
  s.add_dependency 'acts_as_tree', '0.1.1'

  # reCAPTCHA
  s.add_dependency "recaptcha", '0.3.4'

  # Thinking Sphinx
  s.add_dependency 'thinking-sphinx', '2.0.12'
  s.add_dependency 'ts-delayed-delta', '1.1.3'

  s.add_dependency 'term-ansicolor'


  #, :require => "bcrypt"
  #, :require => 'RMagick'
  #, :require => 'openid'
  #, :require => 'dynamic_image'
  #, :require => "recaptcha/rails"
  #, :require => 'thinking_sphinx/deltas/delayed_delta'

end
