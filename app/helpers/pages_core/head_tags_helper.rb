# frozen_string_literal: true

module PagesCore
  module HeadTagsHelper
    def document_title_tag(separator: " - ")
      parts = [document_title, PagesCore.config.site_name]
      tag.title(parts.compact_blank.uniq.join(separator))
    end

    def meta_image_url(image, size: "1200x")
      return if image.blank?
      return image unless image.is_a?(Image)

      dynamic_image_url(image, size:, only_path: false)
    end

    def pages_meta_tags(page = nil)
      safe_join(
        [(tag.meta(name: "robots", content: "noindex") if page&.skip_index?),
         meta_description_tag(meta_description(page)),
         meta_image_tag(meta_image(page)),
         open_graph_tags(page)].compact_blank, "\n"
      )
    end

    private

    def meta_description(record = nil)
      description = content_for(:meta_description)
      description ||= record.meta_description if record.try(&:meta_description?)
      description ||= record.excerpt if record.try(&:excerpt?)
      strip_tags(description)&.strip
    end

    def meta_description_tag(content)
      return if content.blank?

      tag.meta(name: "description", content:)
    end

    def meta_image(record = nil)
      meta_image_url(
        content_for(:meta_image) ||
          record.try(:meta_image) || record.try(:image)
      )
    end

    def meta_image_tag(href)
      return if href.blank?

      tag.link(rel: "image_src", href:)
    end

    def open_graph_description(record = nil)
      if content_for?(:open_graph_description)
        content_for(:open_graph_description)
      elsif record.try(:open_graph_description?)
        record.open_graph_description
      else
        meta_description(record)
      end
    end

    def open_graph_properties(record = nil)
      { type: "website",
        site_name: PagesCore.config(:site_name),
        title: open_graph_title(record),
        image: meta_image(record),
        description: open_graph_description(record)&.strip,
        url: request.url }
    end

    def open_graph_tags(record = nil)
      safe_join(
        open_graph_properties(record)
          .compact
          .map { |name, content| tag.meta(property: "og:#{name}", content:) },
        "\n"
      )
    end

    def open_graph_title(record = nil)
      if content_for?(:open_graph_title)
        content_for(:open_graph_title)
      elsif record.try(:open_graph_title?)
        record.open_graph_title
      else
        document_title
      end
    end
  end
end
