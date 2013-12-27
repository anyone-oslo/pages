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

# Assets
require 'jquery/rails/engine'
require 'jquery/ui/rails'
require 'jquery-cookie-rails'
require 'underscore-rails'
require 'jcrop-rails'

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
require 'thinking_sphinx/deltas/delayed_delta'


module PagesCore
  class << self

    def load_dependencies!
      load 'language.rb'

      load 'pages_core/plugin.rb'

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
      if block_given?
        if options[:reset] == :defaults
          load_default_configuration
        elsif options[:reset] === true
          @@configuration = PagesCore::Configuration::SiteConfiguration.new
        end
        yield self.configuration if block_given?
      else
        # Legacy
        options.each do |key,value|
          self.config(key, value)
        end
      end
    end

    def load_default_configuration
      @@configuration = PagesCore::Configuration::SiteConfiguration.new

      config.localizations       :disabled
      config.page_cache          :enabled
      config.text_filter         :textile

      config.default_author      nil
      #config.comment_notifications [:author, 'your@email.com']
    end

    def configuration(key=nil, value=nil)
      load_default_configuration unless defined? @@configuration
      if key
        configuration.send(key, value) if value != nil
        configuration.get(key)
      else
        @@configuration
      end
    end
    alias :config :configuration
  end

end

PagesCore.init!