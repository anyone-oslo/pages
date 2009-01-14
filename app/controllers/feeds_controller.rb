class FeedsController < ApplicationController
	
	def rss
		@page = Page.find_by_slug_and_language( params[:slug], params[:language] )
		@site_name = BackstageEngine.config :site_name rescue ""
		@items = @page.pages( :language => params[:language] ).reject{ |p| p.body.to_s.strip == "" }
		headers[ "Content-Type" ] = "application/xml; charset=utf-8" 
		render :layout => false
	end
	
end
