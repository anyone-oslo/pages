# frozen_string_literal: true

module Admin
  class CalendarsController < Admin::AdminController
    before_action :find_year_and_month

    require_authorization object: Page

    def show
      unless @year
        redirect_to(admin_calendar_path(content_locale, Time.zone.now.year))
        return
      end
      @pages = if @month
                 calendar_items.in_year_and_month(@year, @month)
               else
                 calendar_items.in_year(@year)
               end
    end

    private

    def calendar_items
      Page.with_dates
          .order(starts_at: :desc)
          .in_locale(content_locale)
          .visible
          .paginate(per_page: 50, page: params[:page])
    end

    def find_year_and_month
      @year = params[:year]&.to_i
      @month = params[:month]&.to_i
    end
  end
end
