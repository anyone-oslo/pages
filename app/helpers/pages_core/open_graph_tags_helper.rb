# frozen_string_literal: true

module PagesCore
  module OpenGraphTagsHelper
    def open_graph_properties
      @open_graph_properties ||= {}
    end

    # Outputs Open Graph tags for Facebook.
    def open_graph_tags
      properties = default_open_graph_properties.merge(open_graph_properties)
      safe_join(
        properties
          .delete_if { |_, content| content.nil? }
          .map do |name, content|
          tag(:meta, property: "og:#{name}", content: content)
        end,
        "\n"
      )
    end

    private

    def default_open_graph_title
      if @page.try(:open_graph_title?)
        @page.open_graph_title
      else
        document_title
      end
    end

    def default_open_graph_description
      if @page.try(:open_graph_description?)
        @page.open_graph_description
      elsif meta_description?
        meta_description
      end
    end

    def default_open_graph_properties
      {
        type: "website",
        site_name: PagesCore.config(:site_name),
        title: default_open_graph_title,
        image: (meta_image if meta_image?),
        description: default_open_graph_description,
        url: request.url
      }
    end
  end
end
