# frozen_string_literal: true

module PagesCore
  module PreviewPagesController
    extend ActiveSupport::Concern
    include PagesCore::PageParameters

    included do
      before_action :disable_xss_protection, only: %i[preview]
    end

    def preview?
      @preview || false
    end

    def preview
      render_error 403 unless logged_in?

      @preview = true
      @page = Page.find_by(id: params[:page_id]) || Page.new
      @page.readonly!
      @page.assign_attributes(preview_page_params)

      render_page
    end

    private

    def disable_xss_protection
      # Disabling this is probably not a good idea,
      # but the header causes Chrome to choke when being
      # redirected back after a submit and the page contains an iframe.
      response.headers["X-XSS-Protection"] = "0"
    end

    def preview_page_params
      ActionController::Parameters.new(
        JSON.parse(params.require(:preview_page))
      ).permit(:id, page_content_attributes).merge(
        status: 2,
        published_at: Time.zone.now,
        locale: content_locale,
        redirect_to: nil
      )
    end
  end
end
