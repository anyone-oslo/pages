# encoding: utf-8

module PagesCore
  module Admin
    module NewsPageController
      extend ActiveSupport::Concern

      included do
        before_action :require_news_pages, only: [:news]
        before_action :find_news_pages, only: [:news, :new_news]
      end

      def news
        @archive_finder = archive_finder(@news_pages, @locale)
        @year, @month = year_and_month(@archive_finder)
        @year ||= Time.zone.now.year
        @month ||= Time.zone.now.month

        @pages = @archive_finder.by_year_and_month(@year, @month)
      end

      def new_news
        new
        render action: :new
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
        @news_pages = Page.news_pages.in_locale(@locale)
        return if @news_pages.any?
        redirect_to(admin_pages_url(@locale))
      end

      # Redirect away if no news pages has been configured
      def require_news_pages
        return if Page.news_pages.any?
        redirect_to(admin_pages_url(@locale))
      end

      def year_and_month(archive_finder)
        if params[:year] && params[:month]
          [params[:year], params[:month]].map(&:to_i)
        else
          archive_finder.latest_year_and_month
        end
      end
    end
  end
end
