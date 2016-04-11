module PagesCore
  module Frontend
    class PagesController < ::FrontendController
      include PagesCore::FrontendHelper
      include PagesCore::Templates::ControllerActions
      include PagesCore::HeadTagsHelper

      include PagesCore::PreviewPagesController
      include PagesCore::RssController

      caches_page :index if PagesCore.config(:page_cache)

      before_action :load_root_pages
      before_action :find_page_by_path, only: [:show]
      before_action :find_page, only: %i[show preview]
      before_action :require_page, only: %i[show preview]
      before_action :canonicalize_url, only: [:show]
      after_action :cache_page_request, only: [:show]

      def index
        respond_to do |format|
          format.html { render_published_page(root_pages.try(&:first)) }
          format.rss { render_rss(all_feed_items) }
        end
      end

      def show
        respond_to do |format|
          format.html { render_published_page(@page) }
          format.rss { render_rss(@page.pages.limit(20), title: @page.name) }
          format.json { render json: @page }
        end
      end

      private

      def canonical_path(page)
        if page.redirects?
          page.redirect_path(locale: page.locale)
        else
          page_path(page.locale, page)
        end
      end

      def canonicalize_url
        return if @page.redirects?
        return if request.path == canonical_path(@page)
        # Don't canonicalize if any unknown params are present
        return if (params.keys - %w[controller action path locale id]).any?
        redirect_to(canonical_path(@page), status: :moved_permanently)
      end

      def render(*args)
        @already_rendered = true
        super
      end

      def redirect_to(*args)
        @already_rendered = true
        super
      end

      def render_page
        return if redirect_page(@page)

        unless document_title?
          document_title(@page.meta_title? ? @page.meta_title : @page.name)
        end

        template = @page.template_config
        run_template_actions_for(template.id, @page)
        return if @already_rendered
        render template: template.path
      end

      # Cache pages by hand. This is dirty, but it works.
      def cache_page_request
        status_code = response.status.try(&:to_i)
        unless status_code == 200 &&
               PagesCore.config(:page_cache) &&
               @page && @locale
          return
        end

        self.class.cache_page response.body, request.path
      end

      def find_page_by_path
        return unless params[:path]
        @page = PagePath.get(locale, params[:path]).try(&:page)
      end

      def find_page
        @page ||= Page.find_by(id: params[:id]) || unique_page(params[:id])
        @page.locale = @locale || I18n.default_locale.to_s if @page
      end

      def render_published_page(page)
        if page && page.published?
          @page = page
          render_page
        else
          render_error 404
        end
      end

      def redirect_page(page)
        return false unless page.redirects?
        redirect_to(page.redirect_path(locale: locale))
      end

      def require_page
        return if @page
        render_error 404
      end
    end
  end
end
