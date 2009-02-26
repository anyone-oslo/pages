class XmlController < FrontendController

	def sitemap
		@rss_feeds = Page.find( :all, :conditions => 'feed_enabled = 1 AND status = 2' ).collect{ |p| p.working_language = @language; p }

		# cache everything
		Page.find( :all )
		
		# grab root pages
        @pages = Page.root_pages(:language => @language) 
		render :layout => false
	end

end
