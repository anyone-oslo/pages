class PagesController < FrontendController

	include ApplicationHelper

	if PagesCore.config(:page_cache)
		caches_page :index
	end
	
	def send_cache_headers
		if PagesCore.config(:http_caching)
			cache_time = 2.minutes
			response.headers['Cache-Control'] = "max-age: #{cache_time.to_s}, must-revalidate"
			response.headers['Expires']       = (Time.now + cache_time).to_formatted_s(:rfc822)
		end
	end
	before_filter :send_cache_headers
	protected     :send_cache_headers


	before_filter :find_page, :only => [ :show ]
	
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
				render_page
			else
				@comment.save
				redirect_to page_url(@page) and return
			end
		else
			redirect_to page_url(@page) and return
		end
	end


	def index
		if self.respond_to? :no_page_given
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
	
	# Search pages
	def search
        @search_query = params[:q] || ""
        normalized_query = @search_query.split(/\s+/).map{|p| "*#{p}*"}.join(' ')
        @pages = Page.find_by_contents(normalized_query, {:limit => :all}, {:conditions => 'status = 2'})
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
				@feed_items = @page.pages(:paginate => {:page => params[:page], :per_page => 20})
				response.headers['Content-Type'] = "application/rss+xml;charset=#{@encoding.upcase}";
				render :template => 'feeds/rss', :layout => false
			end
		end
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
	
	
	
	protected

		before_filter :load_root_pages
		
		def find_page
			unless @page
				if params[:id]
					@page = Page.find(params[:id]) rescue nil
					@page ||= Page.find_by_slug_and_language(params[:id], @language)
				end
			end
		end
	
		def render_page
			@page.working_language = @language || Language.default

			if @page.redirects?
				redirect_to(@page.redirect_to_options({:language => @language})) and return
			end

			@page_title ||= @page.name.to_s

			# Call template methods
			template = @page.template
			template = "index" unless Page.available_templates.include? template
			self.method( "template_#{template}" ).call if self.methods.include? "template_#{template}"
			
			if @redirect
				return
			end
			
			if @disable_layout
				render :template => "pages/templates/#{template}", :layout => false
			else
				render :template => "pages/templates/#{template}"
			end
		end
		
		# Cache pages by hand. This is dirty, but it works.
		def cache_page_request
			if PagesCore.config(:page_cache) && @page && @language
				request_options = {:controller => 'pages', :action => :show, :id => @page, :language => @language, :only_path => true}
				request_options[:page] = params[:page] if params[:page]
				request_options[:category_name] = params[:category_name] if params[:category_name]
				request_path = url_for(request_options) 
				request_path += ".#{params[:format]}" if params[:format]
				self.class.cache_page response.body, request_path
			end
		end
		after_filter :cache_page_request, :only => [ :show ]
		
end
