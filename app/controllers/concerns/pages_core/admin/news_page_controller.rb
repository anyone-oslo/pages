# frozen_string_literal: true

module PagesCore
  module Admin
    module NewsPageController
      extend ActiveSupport::Concern

      included do
        before_action :require_news_pages, only: [:news]
        before_action :find_news_pages, only: %i[news new_news]
      end

      def news
        @archive_finder = archive_finder(@news_pages, @locale)

        unless params[:year]
          redirect_to(news_admin_pages_path(@locale,
                                            (@archive_finder.latest_year ||
                                             Time.zone.now.year)))
          return
        end

        @year = params[:year]&.to_i
        @month = params[:month]&.to_i

        @pages = (if @month
                    @archive_finder.by_year_and_month(@year, @month)
                  else
                    @archive_finder.by_year(@year)
                  end).paginate(per_page: 50, page: params[:page])
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
        @news_pages = Page.news_pages
                          .in_locale(@locale)
                          .reorder("parent_page_id ASC, position ASC")
        return if @news_pages.any?

        redirect_to(admin_pages_url(@locale))
      end

      # Redirect away if no news pages has been configured
      def require_news_pages
        return if Page.news_pages.any?

        redirect_to(admin_pages_url(@locale))
      end

      def latest_year
        archive_finder.latest_year_and_month.first || Time.zone.now.year
      end
    end
  end
end
