# frozen_string_literal: true

xml << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
xml.rss("version" => "2.0", "xmlns:media" => "http://search.yahoo.com/mrss/") do
  xml.channel do
    xml.title(@title || PagesCore.config(:site_name))
    xml.link(root_url)
    xml.description "Recent items"
    xml.language locale.to_s
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
          image_size = "1200x"
          image_url = dynamic_image_url(item.image, size: image_size,
                                                    format: DynamicImage::COMPATIBLE_FORMATS,
                                                    only_path: false)
          image_type = DynamicImage::FormatNegotiator.new(item.image)
                                                     .negotiate(DynamicImage::COMPATIBLE_FORMATS)
                                                     .content_type
          image_dimensions = DynamicImage::ImageSizing.new(item.image).fit(image_size).floor
          xml.tag!("media:content",
                   url: image_url,
                   medium: "image",
                   type: image_type,
                   width: image_dimensions.x,
                   height: image_dimensions.y) do
            xml.tag!("media:title", item.image.caption) if item.image.caption?
            xml.tag!("media:description", item.image.alt_text) unless item.image.alt_text.nil?
          end
          xml.enclosure(
            url: image_url,
            length: 0,
            type: image_type
          )
        end
      end
    end
  end
end
