# encoding: utf-8

require 'digest/sha1'
require 'iconv'
require 'find'
require 'open-uri'
require 'pathname'

# -----

# Framework
require "rails"
require 'active_record'
require 'action_controller'
require 'action_view'
require 'action_mailer'

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
require 'pages_console'
require 'openid'
require 'delayed_job'

require 'dynamic_image'

require 'sass'
require 'json'
require 'coffee-script'

require 'acts_as_list'
require 'acts_as_tree'

require "recaptcha/rails"

require 'thinking-sphinx'
require 'thinking_sphinx/deltas/delayed_delta'

# -----

# Included in lib/
require 'acts_as_taggable'
require 'language'

# Load ./pages_core/*.rb
require 'pages_core/plugin'

require 'pages_core/array_extensions'
require 'pages_core/cache_sweeper'
require 'pages_core/configuration'
require 'pages_core/engine'
require 'pages_core/hash_extensions'
require 'pages_core/localizable'
require 'pages_core/methoded_hash'
require 'pages_core/pages_plugin'
require 'pages_core/paginates'
require 'pages_core/string_extensions'
require 'pages_core/templates'
require 'pages_core/version'

module PagesCore
  class << self
    def init!
      # Register default mime types
      Mime::Type.register "application/rss+xml", 'rss'

      # Register with PagesConsole
      PagesCore.register_with_pages_console
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

    def register_with_pages_console
      begin
        require 'pages_console'
        site = PagesConsole::Site.new(self.application_name, Rails.root.to_s)
        PagesConsole.ping(site)
      rescue MissingSourceFile
        # Nothing to do, PagesConsole not installed.
      end
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
