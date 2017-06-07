# encoding: utf-8

module PagesCore
  module PreviewPagesController
    extend ActiveSupport::Concern

    included do
      before_action :disable_xss_protection, only: [:preview]
    end

    def preview
      redirect_to(page_url(@locale, @page)) && return unless logged_in?
      @page.attributes = page_params.merge(
        status: 2,
        published_at: Time.zone.now,
        locale: @locale,
        redirect_to: nil
      )
      render_page
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
         redirect_to comments_allowed image_link news_page
         unique_name pinned parent_page_id]
    end

    def page_params
      params.require(:page).permit(
        Page.localized_attributes + permitted_page_attributes
      )
    end
  end
end
