# encoding: utf-8

class PagesCore::ApplicationController < ActionController::Base
  include PagesCore::Authentication
  include PagesCore::DomainBasedCache
  include PagesCore::ExceptionHandler
  include PagesCore::ProcessTitler
  include PagesCore::OpenidHelper

  before_action :set_locale
  after_action  :set_content_language_header

  protected

  # Sets @locale from params[:locale], with Language.default as fallback
  def set_locale
    @locale = params[:locale] || Language.default
  end

  def set_content_language_header
    if @locale && definition = Language.definition(@locale.to_s)
      headers['Content-Language'] = definition.iso639_1
    end
  end
end
