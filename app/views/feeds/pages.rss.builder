# encoding: utf-8

converter = Iconv.new( @encoding + "//TRANSLIT", 'utf-8' )

xml << "<?xml version=\"1.0\" encoding=\"" + @encoding.upcase + "\"?>\n"
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
	xml.channel do
		xml.title(converter.iconv(@title))
		xml.link(url_for(:controller => 'pages', :action => 'index', :only_path => false))
		xml.description "Recent items"
		xml.language Language.definition(@language).iso639_1
		xml.generator "Pages"
		xml.ttl "40"
		for item in @feed_items
			xml.item do
				xml.title       { xml.cdata! converter.iconv(item.name.to_s) }
				xml.link        page_url( item, :only_path => false )
				if PagesCore.config.rss_fulltext?
					xml.description { xml.cdata! converter.iconv( item.body.to_html ) }
				else
					xml.description { xml.cdata! converter.iconv( (item.extended? ? item.excerpt : item.body).to_html ) }
				end
				xml.guid        page_url( item, :only_path => false )
				xml.pubDate     item.published_at.to_formatted_s( :rfc822 )
				xml.tag!("dc:creator", converter.iconv( item.author.realname ) )
				if item.image
					image_size = item.image.data.length rescue 0
					xml.enclosure :url => dynamic_image_url(item.image, :only_path => false), :length => image_size, :type => item.image.content_type
				end
			end
		end
	end
end
