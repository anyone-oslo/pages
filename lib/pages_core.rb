# encoding: utf-8

# Ruby Standard Library
require "digest/sha1"
require "fileutils"
require "find"
require "open-uri"
require "pathname"
require "ostruct"

# Rails
require "rails"
require "active_record"
require "action_controller"
require "action_view"
require "action_mailer"

# Gems
require "actionpack/page_caching"
require "active_model_serializers"
require "acts_as_list"
require "bcrypt"
require "coffee-script"
require "delayed_job"
require "dis"
require "dynamic_image"
require "json"
require "rails_i18n"
require "recaptcha/rails"
require "RedCloth"
require "sass"
require "thinking-sphinx"

# Assets
require "jquery/rails/engine"
require "jquery-ui-rails"
require "jquery-cookie-rails"
require "underscore-rails"
require "jcrop/rails/v2"
require "font-awesome-rails"

module PagesCore
  class NotAuthorized < StandardError; end

  class << self
    def load_dependencies!
      load "pages_core/plugin.rb"

      load "pages_core/admin_menu_item.rb"
      load "pages_core/archive_finder.rb"
      load "pages_core/cache_sweeper.rb"
      load "pages_core/configuration.rb"
      load "pages_core/engine.rb"
      load "pages_core/extensions.rb"
      load "pages_core/localizable.rb"
      load "pages_core/page_path_constraint.rb"
      load "pages_core/pages_plugin.rb"
      load "pages_core/paginates.rb"
      load "pages_core/templates.rb"
      load "pages_core/version.rb"
    end

    def init!
      load_dependencies!
    end

    def version
      VERSION
    end

    def plugin_root
      Pathname.new(File.dirname(__FILE__)).join("..").expand_path
    end

    def configure(_options = {}, &_block)
      yield configuration if block_given?
    end

    def configuration(key = nil, *args)
      @configuration ||= PagesCore::Configuration::Pages.new
      if key
        @configuration.send(key, *args)
      else
        @configuration
      end
    end
    alias_method :config, :configuration
  end
end

PagesCore.init!
