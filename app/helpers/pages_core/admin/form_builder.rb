module PagesCore
  module Admin
    class FormBuilder < PagesCore::FormBuilder
      include DynamicImage::Helper

      def rich_text_area(attr, options = {})
        @template.rich_text_area_tag(
          "#{object_name}[#{attr}]",
          object.send(attr),
          options
        )
      end

      def image_uploader(attr, options = {})
        @template.image_uploader_tag(
          "#{object_name}[#{foreign_key(attr)}]",
          object.send(attr),
          options
        )
      end

      def labelled_rich_text_area(attribute, label_text = nil, options = {})
        labelled_field(attribute, label_text, options) do |opts|
          rich_text_area(attribute, opts)
        end
      end

      def labelled_image_uploader(attribute, label_text = nil, options = {})
        labelled_field(attribute, label_text, options) do |opts|
          image_uploader(attribute, opts)
        end
      end

      private

      def foreign_key(attr)
        object.class.reflections[attr.to_s].options[:foreign_key] ||
          "#{attr}_id".to_sym
      end
    end
  end
end
