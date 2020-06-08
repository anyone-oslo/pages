# frozen_string_literal: true

xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do |urlset|
  @entries.each do |entry|
    urlset.url do |url|
      url.loc entry[:loc]
      url.lastmod entry[:lastmod]
    end
  end
end
