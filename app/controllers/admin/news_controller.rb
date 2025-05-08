# frozen_string_literal: true

module Admin
  class NewsController < Admin::AdminController
    before_action :require_news_pages
    before_action :find_news_pages
    before_action :find_year_and_month

    require_authorization object: Page

    def index
      @archive_finder = archive_finder(@news_pages, content_locale)
      unless @year
        redirect_to(admin_news_index_path(content_locale,
                                          @archive_finder.latest_year ||
                                           Time.zone.now.year))
        return
      end
      @pages = @archive_finder.by_year_and_maybe_month(@year, @month)
                              .paginate(per_page: 50, page: params[:page])
    end

    private

    def archive_finder(parents, locale)
      Page.where(parent_page_id: parents)
          .visible
          .order("published_at DESC")
          .in_locale(locale)
          .archive_finder
    end

    def find_news_pages
      @news_pages = Page.news_pages
                        .in_locale(content_locale)
                        .sort { |a, b| b.children.count <=> a.children.count }
      return if @news_pages.any?

      redirect_to(admin_pages_url(content_locale))
    end

    def find_year_and_month
      @year = params[:year]&.to_i
      @month = params[:month]&.to_i
    end

    # Redirect away if no news pages has been configured
    def require_news_pages
      return if Page.news_pages.any?

      redirect_to(admin_pages_url(content_locale))
    end

    def latest_year
      archive_finder.latest_year_and_month.first || Time.zone.now.year
    end
  end
end
