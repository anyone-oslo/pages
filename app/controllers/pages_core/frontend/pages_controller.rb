# encoding: utf-8

class PagesCore::Frontend::PagesController < FrontendController

  if PagesCore.config(:page_cache)
    caches_page :index
  end

  before_filter :load_root_pages
  before_filter :find_page, :only => [:show]
  after_filter  :cache_page_request, :only => [ :show ]


  protected

    def preview?
      @page.new_record?
    end

    def render(*args)
      @already_rendered = true
      super
    end

    def find_page
      unless @page
        if params[:id]
          @page = Page.find(params[:id]) rescue nil
          @page ||= unique_page(params[:id])
          @page ||= Page.find_by_slug_and_language(params[:id].to_s, @language)
        end
      end
    end

    # Set a different layout for a page template
    def page_template_layout(layout_name)
      @page_template_layout = layout_name
    end

    def render_page
      @page.working_language = @language || Language.default

      if @page.redirects?
        redirect_to @page.redirect_path(:locale => @language) and return
      end

      @page_title ||= @page.name.to_s

      # Call template method
      template = @page.template
      template = "index" unless PagesCore::Templates.names.include?(template)
      self.method("template_#{template}").call if self.respond_to?("template_#{template}")

      if @redirect
        return
      end

      @page_template_layout = false if @disable_layout

      unless @already_rendered
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
      if status_code == 200 && PagesCore.config(:page_cache) && @page && @language
        #request_options = {:controller => 'pages', :action => :show, :id => @page, :language => @language, :only_path => true}
        #request_options[:page] = params[:page] if params[:page]
        #request_options[:category_name] = params[:category_name] if params[:category_name]
        #request_options[:sort] = params[:sort] if params[:sort]
        #request_path = url_for(request_options)
        #request_path += ".#{params[:format]}" if params[:format] && params[:format].to_s != 'html'
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
          feeds       = Page.enabled_feeds(@language, {:include_hidden => true})
          @feed_items = Page.get_pages(:paginate => {:page => 1, :per_page => 20}, :parent => feeds, :order => 'published_at DESC')
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
          @page.working_language = @language || Language.default
          @page_title ||= @page.name.to_s
          @title = [PagesCore.config(:site_name), @page.name.to_s].join(": ")

          if params[:category_name]
            @category = Category.find_by_name(params[:category_name].to_s)
            @feed_items = @page.pages(:paginate => {:page => params[:page], :per_page => 20}, :category => @category)
          else
            @feed_items = @page.pages(:paginate => {:page => params[:page], :per_page => 20})
          end

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
      @comment = PageComment.new(params[:page_comment].merge({:remote_ip => remote_ip, :page_id => @page.id}))
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
              AdminMailer.deliver_comment_notification(r, :page => @page, :comment => @comment, :url => page_url(@page))
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
      normalized_query = @search_query.split(/\s+/).map{|p| "#{p}*"}.join(' ')
      @pages = Page.search_paginated(normalized_query, :page => params[:page], :with => {:status => 2}, :order => :published_at, :sort_mode => :desc)
    end

    def preview
      @page = Page.new(params[:page])
      @page.published_at ||= Time.now
      render_page
    end

    def sitemap
      if params[:root_id]
        page = Page.find( params[:root_id] ) rescue nil
        if page
          @pages = page.pages(:language => @language)
        end
      end
      unless @pages
        @pages = Page.root_pages(:language => @language)
      end
      render :layout => false
    end

end
