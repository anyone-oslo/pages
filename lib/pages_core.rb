# frozen_string_literal: true

# Ruby Standard Library
require "digest/sha1"
require "fileutils"
require "find"
require "open-uri"
require "pathname"

# Rails
require "rails"
require "active_record"
require "action_controller"
require "action_view"
require "action_mailer"

# Gems
require "actionpack/page_caching"
require "acts_as_list"
require "alba"
require "bcrypt"
require "country_select"
require "dis"
require "dynamic_image"
require "healthcheck"
require "localizable_model"
require "lograge"
require "nokogiri"
require "json"
require "pg_search"
require "premailer/rails"
require "progress_bar"
require "rails_i18n"
require "RedCloth"
require "rotp"
require "rqrcode"
require "sass-rails"
require "typhoeus"
require "will_paginate"

# Must be loaded so that PagesCore::LinkRender can resolve the constant.
require "will_paginate/view_helpers/action_view"

# Assets
require "react-rails"

# Pages
require "pages_core/plugin"
require "pages_core/admin_menu_item"
require "pages_core/archive_finder"
require "pages_core/attachment_embedder"
require "pages_core/cache_sweeper"
require "pages_core/digest_verifier"
require "pages_core/configuration"
require "pages_core/engine"
require "pages_core/extensions"
require "pages_core/page_path_constraint"
require "pages_core/pages_plugin"
require "pages_core/pub_sub"
require "pages_core/templates"
require "pages_core/version"

module PagesCore
  class NotAuthorized < StandardError; end

  class << self
    def version
      VERSION
    end

    def deprecator
      @deprecator ||= ActiveSupport::Deprecation.new("3.17", "PagesCore")
    end

    def plugin_root
      Pathname.new(File.dirname(__FILE__)).join("..").expand_path
    end

    def configure(_options = {}, &)
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

    def reset_configuration!
      @configuration = PagesCore::Configuration::Pages.new
    end
  end
end
