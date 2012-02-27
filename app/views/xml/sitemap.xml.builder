# encoding: utf-8

def page_to_xml( xml, page )
	xml.page( "id" => page.id ) do
		xml.name   page.name
		xml.slug   page.slug
		#xml.url    url_for( :controller => 'pages', :language => @language, :slug => page.slug.to_s, :only_path => false )
		xml.url    page_url(page, :only_path => false)
		xml.author( page.author.realname.to_s, "id" => page.author.id ) if page.author
		xml.pubDate page.published_at.to_formatted_s( :rfc822 )
		xml.modDate page.updated_at.to_formatted_s( :rfc822 )

		unless page.pages.empty?
			page.pages.each do |p|
				page_to_xml xml, p
			end
		end

	end
end

xml.sitemap do

	xml.title    PagesCore.config :site_name
	xml.language @language

	unless @rss_feeds.empty?
		xml.feeds do
			@rss_feeds.each do |feed|
				xml.feed( url_for( :controller => 'feeds', :action => :rss, :slug => feed.slug.to_s, :language => @language, :only_path => false ), 'name' => feed.name.to_s )
			end
		end
	end

	xml.pages do |x|

		@pages.each do |page|
			page_to_xml x, page
		end

	end

end