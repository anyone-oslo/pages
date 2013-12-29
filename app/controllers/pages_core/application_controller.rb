# encoding: utf-8

class PagesCore::ApplicationController < ActionController::Base
  include PagesCore::Authentication
  include PagesCore::ExceptionHandler
  include PagesCore::ProcessTitler
  include PagesCore::OpenidHelper

  # Actions added to the SKIP_FILTERS array will be bypassed by filters.
  # Useful for actions that don't rely on PagesCore.
  SKIP_FILTERS = [:render_dynamic_image]

  before_action :domain_cache
  before_action :set_locale,                 :except => SKIP_FILTERS
  after_action  :set_headers,                :except => SKIP_FILTERS

  protected

  def domain_cache
    if PagesCore.config(:domain_based_cache)
      @@default_page_cache_directory ||= @@page_cache_directory
      @@page_cache_directory = File.join(@@default_page_cache_directory, request.domain)
    end
  end

  # Redirect to the previous page, falling back to the options specified if that fails.
  # Example:
  #
  #   redirect_back_or_to "/"
  #
  def redirect_back_or_to(options={}, response_status={})
    begin
      redirect_to :back
    rescue #RedirectBackError
      redirect_to options, response_status
    end
  end

  # Sets @locale from params[:locale], with Language.default as fallback
  def set_locale
    if params[:language]
      ActiveSupport::Deprecation.warn "params[:language] is deprecated, use params[:locale]"
    end
    @language = @locale = params[:locale] || params[:language] || Language.default
  end

  # Sends HTTP headers (Content-Language etc) to the client.
  # This method is automatically run from an after_action.
  def set_headers
    # Set the language header
    headers['Content-Language'] = Language.definition(@locale.to_s).iso639_1 rescue nil if @locale
  end
end
