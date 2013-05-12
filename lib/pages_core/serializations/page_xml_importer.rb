module PagesCore
  module Serializations
    class PageXmlImporter

      def initialize(page, xmldata)
        @page, @xmldata = page, xmldata
      end

      def import_xml(xmldata)
        created_pages = []
        page_elements do |page_xml|
          attributes = attributes_from_xml.merge(parent_page_id: @page.id)

          if attributes.has_key?('author_email')
            author = User.exists?(email: attributes['author_email']) ? User.find_by_email(attributes['author_email'].to_s): @page.author
            attributes.delete('author_email')
          else
            author = @page.author
          end

          page = Page.new.localize(@page.locale)
          page.author = author
          if page.update_attributes(attributes)
            created_pages << page
          end
        end
        created_pages
      end

      private

      def attributes_from_xml
        Hash.from_xml(page_xml.to_s)['page']
      end

      def doc
        @doc ||= REXML::Document.new(@xmldata)
      end

      def page_elements
        doc.elements.each('pages/page')
      end
    end
  end
end