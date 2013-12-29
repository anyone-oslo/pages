# encoding: utf-8

class PagesCore::Frontend::PagesController < FrontendController
  include PagesCore::Templates::ControllerActions

  if PagesCore.config(:page_cache)
    caches_page :index
  end

  before_action :load_root_pages
  before_action :find_page, :only => [:show, :preview]
  after_action  :cache_page_request, :only => [ :show ]


  protected

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
      @already_rendered
    end

    def find_page
      unless @page
        if params[:id]
          @page = Page.find(params[:id]) rescue nil
          @page ||= unique_page(params[:id])
        end
      end
    end

    # Set a different layout for a page template
    def page_template_layout(layout_name)
      @page_template_layout = layout_name
    end

    def render_page
      @page.locale = @locale || Language.default

      if @page.redirects?
        redirect_to @page.redirect_path(:locale => @locale) and return
      end

      @page_title ||= @page.name.to_s

      # Call template method
      template = @page.template
      template = "index" unless PagesCore::Templates.names.include?(template)

      run_template_actions_for(template, @page)

      @page_template_layout = false if @disable_layout

      unless rendered?
        if self.instance_variables.include?('@page_template_layout')
          render :template => "pages/templates/#{template}", :layout => @page_template_layout
        else
          render :template => "pages/templates/#{template}"
        end
      end
    end

    # Cache pages by hand. This is dirty, but it works.
    def cache_page_request
      status_code = response.status.to_i rescue nil
      if status_code == 200 && PagesCore.config(:page_cache) && @page && @locale
        self.class.cache_page response.body, request.path
      end
    end

  public

    def index
      respond_to do |format|
        format.html do
          if self.respond_to?(:no_page_given)
            no_page_given
          else
            @page = @root_pages.first rescue nil
          end

          if @page
            render_page
          else
            render_error 404 # TODO: friendly message here
          end
        end
        format.rss do
          @encoding   = (params[:encoding] ||= "UTF-8").downcase
          @title      = PagesCore.config(:site_name)
          feeds       = Page.enabled_feeds(@locale, {:include_hidden => true})
          @feed_items = Page.where(:parent_page_id => feeds).order('publised_at DESC').published.limit(20).localized(@locale)
          response.headers['Content-Type'] = "application/rss+xml;charset=#{@encoding.upcase}";
          render :template => 'feeds/pages', :layout => false
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
          @encoding = (params[:encoding] ||= "UTF-8").downcase
          @page.locale = @locale || Language.default
          @page_title ||= @page.name.to_s
          @title = [PagesCore.config(:site_name), @page.name.to_s].join(": ")

          page = (params[:page] || 1).to_i
          @feed_item = @page.pages.limit(20).offset((page - 1) * 20)

          response.headers['Content-Type'] = "application/rss+xml;charset=#{@encoding.upcase}";
          render :template => 'feeds/pages', :layout => false
        end
      end
    end

    # Add a comment to a page. Recaptcha is performed if PagesCore.config(:recaptcha) is set.
    def add_comment
      @page = Page.find(params[:id]) rescue nil
      unless @page
        redirect_to "/" and return
      end
      remote_ip = request.env["REMOTE_ADDR"]
      page_comment_params = params.require(:page_comment).permit(:name, :email, :url, :body)
      @comment = PageComment.new(page_comment_params.merge({:remote_ip => remote_ip, :page_id => @page.id}))
      if @page.comments_allowed?
        if PagesCore.config(:recaptcha) && !verify_recaptcha
          @comment.invalid_captcha = true
          render_page
        elsif PagesCore.config(:comment_honeypot) && !params[:email].to_s.empty?
          redirect_to page_url(@page) and return
        else
          @comment.save
          if PagesCore.config(:comment_notifications)
            recipients = PagesCore.config(:comment_notifications).map{|r| r = @page.author.realname_and_email if r == :author; r }.uniq
            recipients.each do |r|
              AdminMailer.comment_notification(r, @page, @comment, page_url(@page)).deliver
            end
          end
          redirect_to page_url(@page) and return
        end
      else
        redirect_to page_url(@page) and return
      end
    end

    # Search pages
    def search
      params[:query] = params[:q] if params[:q]
      @search_query = params[:query] || ""
      @search_category_id = params[:category_id]
      normalized_query = @search_query.split(/\s+/).map{|p| "#{p}*"}.join(' ')

      options = {
        page:      params[:page],
        order:     :published_at,
        sort_mode: :desc
      }
      options[:category_id] = @search_category_id if @search_category_id

      @pages = Page.search_paginated(normalized_query, options).map { |p| p.localize(@locale) }
    end

    def preview
      unless @current_user
        redirect_to page_url(@locale, @page) and return
      end

      preview_attributes = params[:page].merge(status: 2, published_at: Time.now, locale: @locale, redirect_to: nil)
      preview_attributes.delete(:serialized_tags)

      @page.attributes = preview_attributes

      render_page
    end

end
