# frozen_string_literal: true

require "builder"

module PagesCore
  class Sitemap
    attr_reader :entries

    def initialize(&)
      @entries = {}
      yield(self) if block_given?
    end

    def add(url, options = {})
      entries[url] = options
    end

    def to_xml
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do |doc|
        entries.each do |url, opts|
          xml_entry(doc, url, opts)
        end
      end
    end

    private

    def format_time(timestamp)
      if timestamp.is_a?(Date)
        timestamp.strftime("%Y-%m-%d")
      else
        timestamp.strftime("%Y-%m-%dT%H:%M:%S#{timestamp.formatted_offset}")
      end
    end

    def xml_entry(doc, entry_url, opts = {})
      doc.url do |url|
        url.loc(entry_url)
        url.lastmod(format_time(opts[:lastmod])) if opts[:lastmod]
        url.changefreq opts[:changefreq] if opts[:changefreq]
        url.priority opts[:priority] if opts[:priority]
      end
    end
  end
end
