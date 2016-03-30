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
require "react-rails"
require "jquery-cookie-rails"
require "underscore-rails"
require "jcrop/rails/v2"
require "font-awesome-rails"

module PagesCore
  class NotAuthorized < StandardError; end

  class << self
    def load_dependencies!
      %w(
        plugin admin_menu_item archive_finder cache_sweeper file_embedder
        configuration engine extensions localizable page_path_constraint
        pages_plugin paginates templates version
      ).each do |dep|
        load("pages_core/#{dep}.rb")
      end
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
    alias config configuration
  end
end

PagesCore.init!
