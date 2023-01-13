# frozen_string_literal: true

module Admin
  module NewsHelper
    def news_page_options(news_pages)
      options_for_select(
        news_pages.map do |p|
          [news_section_name(p, news_pages).gsub("&raquo;", "»"), p.id]
        end
      )
    end
  end
end
