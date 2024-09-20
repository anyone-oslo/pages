# frozen_string_literal: true

xml.instruct!
xml.sitemapindex xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do |index|
  @sitemaps.each do |url|
    index.sitemap do |sitemap|
      sitemap.loc(url)
    end
  end
end
