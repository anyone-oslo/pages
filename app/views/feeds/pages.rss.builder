# frozen_string_literal: true

xml << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
xml.rss("version" => "2.0", "xmlns:media" => "http://search.yahoo.com/mrss/") do
  xml.channel do
    xml.title(@title || PagesCore.config(:site_name))
    xml.link(root_url)
    xml.description "Recent items"
    xml.language locale
    xml.generator "Pages"
    xml.ttl "40"
    @items.each do |item|
      xml.item do
        xml.title { xml.cdata! item.name.to_s }
        xml.link page_url(content_locale, item, only_path: false)
        xml.description do
          if @summary
            xml.cdata!(item.excerpt.to_html)
          else
            xml.cdata!(item.excerpt.to_html + item.body.to_html)
          end
        end
        xml.guid page_url(content_locale, item, only_path: false)
        xml.pubDate item.published_at.to_fs(:rfc822)
        if item.image
          xml.tag!("media:content",
                   url: dynamic_image_url(item.image),
                   medium: "image",
                   fileSize: item.image.content_length,
                   type: item.image.content_type,
                   width: item.image.size.x,
                   height: item.image.size.y) do
            xml.tag!("media:title", item.image.caption) if item.image.caption?
            if item.image.alternative?
              xml.tag!("media:description", item.image.alternative)
            end
          end
          xml.enclosure(
            url: dynamic_image_url(item.image),
            length: item.image.content_length,
            type: item.image.content_type
          )
        end
      end
    end
  end
end
