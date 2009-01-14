class PagesController < ApplicationController

	include ApplicationHelper
	
	def send_cache_headers
		if Backstage.config( :http_caching )
			cache_time = 2.minutes
			response.headers['Cache-Control'] = "max-age: #{cache_time.to_s}, must-revalidate"
			response.headers['Expires']       = ( Time.now + cache_time ).to_formatted_s( :rfc822 )
		end
	end
	before_filter :send_cache_headers
	protected     :send_cache_headers


	before_filter :find_page, :only => [ :show ]
	
	def add_comment
		@page = Page.find( params[:id] ) rescue nil
		unless @page
			redirect_to "/" and return
		end
		remote_ip = request.env["REMOTE_ADDR"]
		@comment = PageComment.new( params[:page_comment].merge( { :remote_ip => remote_ip, :page_id => @page.id } ) )
		if @page.comments_allowed?
			if Backstage.config( :recaptcha ) && !verify_recaptcha
				render_page
			else
				@comment.save
				redirect_to page_url( @page ) and return
			end
		else
			redirect_to page_url( @page ) and return
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
	
	def search
        @search_query = params[:q] || ""
        normalized_query = @search_query.split(/\s+/).map{|p| "*#{p}*"}.join(' ')
        @pages = Page.find_by_contents(normalized_query, {:limit => :all}, {:conditions => 'status = 2'})
    end


	def show
		respond_to do |format|
			format.html do
				if @page
					render_page
				else
					render_error 404
				end
			end
			format.rss do
				@encoding = ( params[:encoding] ||= "UTF-8" ).downcase
				@page.working_language = @language || Language.default
				@page_title ||= @page.name.to_s
				response.headers['Content-Type'] = "application/rss+xml;charset=#{@encoding.upcase}";
				render :template => 'feeds/rss', :layout => false
			end
		end
	end
	
	def sitemap
		if params[:root_id]
			page = Page.find( params[:root_id] ) rescue nil
			if page
				@pages = page.pages( :language => @language )
			end
		end
		unless @pages
			@pages = Page.root_pages( :language => @language )
		end
		render :layout => false
	end
	
	
	
	protected

		before_filter :load_root_pages
		#def load_pages
		#	@root_pages = Page.root_pages( :language => @language )
		#	@rss_feeds = Page.find( :all, :conditions => 'feed_enabled = 1 AND status = 2' ).collect{ |p| p.working_language = @language; p }
		#end
		
		def find_page
			unless @page
				if params[:id]
					@page = Page.find( params[:id] ) rescue nil
					@page ||= Page.find_by_slug_and_language( params[:id], @language )
				end
			end
		end
	
		def render_page
			
			@page.working_language = @language || Language.default

			if @page.redirects?
				redirect_to( @page.redirect_to_options( { :language => @language } ) ) and return
			end

			@root_subpages = @page.root_page.pages( :language => @language )
			
			@page_title ||= @page.name.to_s

			# Call template methods
			template = @page.template
			template = "index" unless Page.available_templates.include? template
			self.method( "template_#{template}" ).call if self.methods.include? "template_#{template}"
			
			if @redirect
				return
			end
			
			if @disable_layout
				render :template => "pages/#{template}", :layout => false
			else
				render :template => "pages/#{template}"
			end
		end

		# Redirect to the first root page if no page is given.
		#def no_page_given
		#	# redirect to first page
		#	if @page = Page.root_pages.first
		#		@page.working_language = @language
		#		redirect_to :slug => @page.slug.to_s, :language => @language, :action => :index
		#	else
		#		render :text => "No pages have been created yet."
		#	end
		#end
	
end
