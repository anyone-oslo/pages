# frozen_string_literal: true

module PagesCore
  module PreviewPagesController
    extend ActiveSupport::Concern

    def preview?
      @preview || false
    end

    private

    def disable_xss_protection
      # Disabling this is probably not a good idea,
      # but the header causes Chrome to choke when being
      # redirected back after a submit and the page contains an iframe.
      response.headers["X-XSS-Protection"] = "0"
    end

    def permitted_page_attributes
      %i[template user_id status feed_enabled published_at
         redirect_to image_link news_page
         unique_name pinned parent_page_id]
    end

    def page_params
      params.require(:page).permit(
        Page.localized_attributes + permitted_page_attributes
      )
    end

    def preview_page(page)
      redirect_to(page_url(content_locale, page)) && return unless logged_in?

      disable_xss_protection

      @preview = true
      page.attributes = page_params.merge(
        status: 2,
        published_at: Time.zone.now,
        locale: content_locale,
        redirect_to: nil
      )
      render_page
    end
  end
end
