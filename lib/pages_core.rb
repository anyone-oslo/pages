# encoding: utf-8

require 'digest/sha1'
require 'find'
require 'open-uri'
require 'pathname'
require 'rexml/document'
require 'ostruct'

# -----

# Framework
require "rails"
require 'active_record'
require 'action_controller'
require 'action_view'
require 'action_mailer'

require 'actionpack/page_caching'
require 'active_model_serializers'

require 'rails_i18n'

# Assets
require 'jquery/rails/engine'
require 'jquery/ui/rails'
require 'jquery-cookie-rails'
require 'underscore-rails'
require 'jcrop/rails/v2'

require "bcrypt"
require 'vector2d'
require 'RedCloth'
require 'daemon-spawn'
require 'openid'
require 'delayed_job'

require 'dynamic_image'

require 'sass'
require 'json'
require 'coffee-script'

require 'acts_as_list'

require "recaptcha/rails"

require 'thinking-sphinx'

module PagesCore
  class NotAuthorized < StandardError; end

  class << self

    def load_dependencies!
      load 'pages_core/plugin.rb'

      load 'pages_core/admin_menu_item.rb'
      load 'pages_core/archive_finder.rb'
      load 'pages_core/cache_sweeper.rb'
      load 'pages_core/configuration.rb'
      load 'pages_core/engine.rb'
      load 'pages_core/extensions.rb'
      load 'pages_core/html_formatter.rb'
      load 'pages_core/localizable.rb'
      load 'pages_core/pages_plugin.rb'
      load 'pages_core/paginates.rb'
      load 'pages_core/serializations.rb'
      load 'pages_core/templates.rb'
      load 'pages_core/version.rb'
    end

    def init!
      load_dependencies!
    end

    def version
      VERSION
    end

    def plugin_root
      Pathname.new(File.dirname(__FILE__)).join('..').expand_path
    end

    def application_name
      dir = Rails.root.to_s
      dir.gsub(/\/current\/?$/, '').gsub(/\/releases\/[\d]+\/?$/, '').split('/').last
    end

    def configure(options={}, &block)
      yield configuration if block_given?
    end

    def configuration(key=nil, *args)
      @configuration ||= PagesCore::Configuration::Pages.new
      if key
        @configuration.send(key, *args)
      else
        @configuration
      end
    end
    alias :config :configuration
  end
end

PagesCore.init!