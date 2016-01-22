# encoding: utf-8

module PagesCore
  module Frontend
    class PagesController < ::FrontendController
      include PagesCore::FrontendHelper
      include PagesCore::Templates::ControllerActions
      include PagesCore::HeadTagsHelper

      caches_page :index if PagesCore.config(:page_cache)

      before_action :disable_xss_protection, only: [:preview]
      before_action :load_root_pages
      before_action :find_page_by_path, only: [:show]
      before_action :find_page, only: [:show, :preview, :add_comment]
      before_action :require_page, only: [:show, :preview, :add_comment]
      before_action :canonicalize_url, only: [:show]
      after_action :cache_page_request, only: [:show]

      def index
        respond_to do |format|
          format.html do
            if self.respond_to?(:no_page_given)
              no_page_given
            elsif root_pages.any?
              @page = root_pages.first
              render_page
            else
              render_error 404
            end
          end
          format.rss do
            render_rss(all_feed_items)
          end
        end
      end

      def show
        respond_to do |format|
          format.html do
            if @page && @page.published?
              render_page
            else
              render_error 404
            end
          end
          format.rss do
            render_rss(
              @page.pages.limit(20),
              title: "#{PagesCore.config(:side_name)}: #{@page.name}"
            )
          end
          format.json do
            render json: @page
          end
        end
      end

      # Add a comment to a page. Recaptcha is performed if
      # PagesCore.config(:recaptcha) is set.
      def add_comment
        @comment = new_comment(@page)

        unless captcha_verified?
          @comment.invalid_captcha = true
          render_page
          return
        end

        if @page.comments_allowed? && !honeypot_triggered?
          @comment.save
          if PagesCore.config(:comment_notifications)
            deliver_comment_notifications(@page, @comment)
          end
        end

        redirect_to(page_url(@locale, @page))
      end

      # Search pages
      def search
        @search_query = params[:q] || params[:query] || ""
        @search_category_id = params[:category_id]

        @pages = Page.search(
          normalize_search_query(@search_query),
          search_options(category_id: @search_category_id)
        )
        @pages.each { |p| p.localize!(locale) }
        @pages
      end

      def preview
        redirect_to(page_url(@locale, @page)) && return unless logged_in?

        @page.attributes = page_params.merge(
          status: 2,
          published_at: Time.now,
          locale: @locale,
          redirect_to: nil
        )

        render_page
      end

      private

      def all_feed_items
        Page
          .where(
            parent_page_id: Page.enabled_feeds(locale, include_hidden: true)
          )
          .order("published_at DESC")
          .published
          .limit(20)
          .localized(locale)
      end

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
        return if (params.keys - %w(controller action path locale id)).any?
        redirect_to(canonical_path(@page), status: :moved_permanently)
      end

      def disable_xss_protection
        # Disabling this is probably not a good idea,
        # but the header causes Chrome to choke when being
        # redirected back after a submit and the page contains an iframe.
        response.headers["X-XSS-Protection"] = "0"
      end

      def preview?
        @page.new_record?
      end

      def render(*args)
        @already_rendered = true
        super
      end

      def redirect_to(*args)
        @already_rendered = true
        super
      end

      def rendered?
        @already_rendered ? true : false
      end

      def page_template(page)
        if PagesCore::Templates.names.include?(page.template)
          page.template
        else
          "index"
        end
      end

      def render_page
        if @page.redirects?
          redirect_to(@page.redirect_path(locale: @locale))
          return
        end

        unless document_title?
          if @page.meta_title?
            document_title(@page.meta_title)
          else
            document_title(@page.name)
          end
        end

        # Call template method
        template = page_template(@page)

        run_template_actions_for(template, @page)

        @page_template_layout = false if @disable_layout

        return if rendered?

        if instance_variables.include?("@page_template_layout")
          render(
            template: "pages/templates/#{template}",
            layout: @page_template_layout
          )
        else
          render template: "pages/templates/#{template}"
        end
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

      def permitted_page_attributes
        [
          :template, :user_id, :status, :feed_enabled, :published_at,
          :redirect_to, :comments_allowed, :image_link, :news_page,
          :unique_name, :pinned, :parent_page_id
        ]
      end

      def page_params
        params.require(:page).permit(
          Page.localized_attributes + permitted_page_attributes
        )
      end

      def captcha_verified?
        !PagesCore.config(:recaptcha) || verify_recaptcha
      end

      def honeypot_triggered?
        PagesCore.config(:comment_honeypot) && !params[:email].to_s.empty?
      end

      def remote_ip
        request.env["REMOTE_ADDR"]
      end

      def new_comment(page)
        PageComment.new(
          page_comment_params.merge(remote_ip: remote_ip, page_id: page.id)
        )
      end

      def comment_recipients(page)
        PagesCore.config(:comment_notifications)
          .map { |r| r == :author ? page.author.name_and_email : r }
          .uniq
      end

      def deliver_comment_notifications(page, comment)
        comment_recipients(page).each do |r|
          AdminMailer.comment_notification(
            r,
            page,
            comment,
            page_url(locale, page)
          ).deliver_now
        end
      end

      def find_page_by_path
        return unless params[:path]
        @page ||= PagePath.get(locale, params[:path]).try(&:page)
      end

      def find_page
        @page ||= find_page_by_id(params[:id]) || unique_page(params[:id])
        @page.locale = @locale || I18n.default_locale.to_s if @page
      end

      def find_page_by_id(id)
        Page.find(id)
      rescue
        nil
      end

      def page_comment_params
        params.require(:page_comment).permit(:name, :email, :url, :body)
      end

      def normalize_search_query(str)
        str
          .split(/\s+/)
          .map { |p| "#{p}*" }
          .join(" ")
      end

      def render_rss(items, title: nil)
        @items, @title = items, title
        response.headers["Content-Type"] = "application/rss+xml;charset=utf-8"
        render template: "feeds/pages", layout: false
      end

      def require_page
        return if @page
        render_error 404
      end

      def search_options(category_id: nil)
        options = {
          page:      (params[:page] || 1).to_i,
          per_page:  20,
          include:   [:localizations, :categories, :image, :author],
          order:     :published_at,
          sort_mode: :desc,
          with: {
            status:      2,
            autopublish: 0
          }
        }
        unless category_id.blank?
          options[:with][:category_ids] = category_id
        end
        options
      end
    end
  end
end
