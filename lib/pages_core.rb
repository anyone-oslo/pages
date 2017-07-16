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
require "country_select"
require "delayed_job"
require "dis"
require "dynamic_image"
require "localizable_model"
require "json"
require "rails_i18n"
require "RedCloth"
require "sass"

# Assets
require "font-awesome-rails"
require "jcrop/rails/v2"
require "jquery-ui-rails"
require "jquery/rails/engine"
require "react-rails"
require "underscore-rails"

# Pages
require "pages_core/plugin"
require "pages_core/admin_menu_item"
require "pages_core/archive_finder"
require "pages_core/cache_sweeper"
require "pages_core/file_embedder"
require "pages_core/configuration"
require "pages_core/engine"
require "pages_core/extensions"
require "pages_core/page_path_constraint"
require "pages_core/pages_plugin"
require "pages_core/paginates"
require "pages_core/templates"
require "pages_core/version"

module PagesCore
  class NotAuthorized < StandardError; end

  class << self
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
