# frozen_string_literal: true

module PagesCore
  class ExternalContentScanner
    attr_reader :page

    def initialize(page)
      @page = page
    end

    def results
      perform_scan! unless @results
      @results
    end

    private

    def perform_scan!
      @results = []
      page.localizations.each { |l| scan_block(l) }
    end

    def report(type, localization, url)
      return if url.blank?

      @results << {
        type:, locale: localization.locale, name: localization.name, url:
      }
    end

    def scan_block(loc)
      doc = Nokogiri::HTML::DocumentFragment.parse(loc.value)
      scan_elem(doc, loc,
                "iframe,img,script,audio,video,embed,track,source", "src")
      scan_elem(doc, loc, "link", "href")
      scan_elem(doc, loc, "object", "data")
      scan_elem(doc, loc, "source", "srcset")
    end

    def scan_elem(doc, localization, selector, attrib)
      doc.search(selector).each do |elem|
        report(elem.name.to_sym, localization, elem.attributes[attrib]&.value)
      end
    end
  end
end
