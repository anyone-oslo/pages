# encoding: utf-8

# Abstract controller for all frontend controllers.
class PagesCore::FrontendController < ApplicationController

  include ApplicationHelper

  before_filter :set_i18n_locale

  # Loads @root_pages and @rss_feeds. To automatically load these in your own controllers,
  # add the following line to your controller definition:
  #
  #   before_filter :load_root_pages
  #
  def load_root_pages
    @root_pages = Page.root_pages( :language => @language )
    @rss_feeds = Page.find( :all, :conditions => 'feed_enabled = 1 AND status = 2' ).collect{ |p| p.working_language = @language; p }
  end

  private

  def set_i18n_locale
    if @language == 'nor'
      I18n.locale = :nb
    else
      I18n.locale = :en
    end
  end

end
