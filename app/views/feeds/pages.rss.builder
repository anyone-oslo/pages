# frozen_string_literal: true

xml << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
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
          xml.cdata! item.excerpt.to_html + item.body.to_html
        end
        xml.guid page_url(content_locale, item, only_path: false)
        xml.pubDate item.published_at.to_fs(:rfc822)
        xml.tag!("dc:creator", item.author.name)
        if item.image
          xml.enclosure(
            url: dynamic_image_url(item.image, size: "2000x2000"),
            length: item.image.content_length,
            type: item.image.content_type
          )
        end
      end
    end
  end
end
