# frozen_string_literal: true

module PagesCore
  module Frontend
    class PagesController < ::FrontendController
      include PagesCore::FrontendHelper
      include PagesCore::Templates::ControllerActions

      include PagesCore::Pages::PreviewController
      include PagesCore::Pages::RssController

      before_action :load_root_pages
      before_action :find_page_by_path, only: [:show]
      before_action :find_page, only: %i[show]
      before_action :require_page, only: %i[show]
      before_action :canonicalize_url, only: [:show]
      static_cache :index, :show

      def index
        respond_to do |format|
          format.html { render_published_page(root_pages.try(&:first)) }
          format.rss do
            render_rss(all_feed_items.paginate(per_page: per_page_rss_param,
                                               page: page_param))
          end
        end
      end

      def show
        respond_to do |format|
          format.html { render_published_page(@page) }
          format.json { render json: PageResource.new(@page) }
          format.rss { render_page_rss(@page, page_param) }
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

      def page_template(page)
        if PagesCore::Templates.names.include?(page.template)
          page.template
        else
          "index"
        end
      end

      def render_page
        return if redirect_page(@page)

        if document_title.blank?
          document_title(@page.meta_title? ? @page.meta_title : @page.name)
        end

        template = page_template(@page)
        run_template_actions_for(template, @page)
        return if @already_rendered

        render template: "pages/templates/#{template}"
      end

      def find_page_by_path
        return unless params[:path]

        @page = PagePath.get(locale, params[:path]).try(&:page)
      end

      def find_page
        @page ||= Page.find_by(id: params[:id]) || unique_page(params[:id])
        @page.locale = content_locale if @page
      end

      def render_published_page(page)
        if page&.published?
          @page = page
          render_page
        else
          render_error 404
        end
      end

      def redirect_to_parent_or_root(page)
        if page.parent
          redirect_to page_url(locale, page.parent)
        else
          redirect_to root_url
        end
      end

      def redirect_page(page)
        return false unless page.redirects?

        redirect_to(page.redirect_path(locale:), allow_other_host: true)
      end

      def require_page
        return if @page

        render_error 404
      end
    end
  end
end
