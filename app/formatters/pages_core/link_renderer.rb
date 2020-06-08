# frozen_string_literal: true

module PagesCore
  class LinkRenderer < WillPaginate::ActionView::LinkRenderer
    def previous_page
      num = @collection.current_page > 1 &&
            @collection.current_page - 1
      previous_or_next_page(num, "Previous", "previous")
    end

    def next_page
      num = @collection.current_page < total_pages &&
            @collection.current_page + 1
      previous_or_next_page(num, "Next", "next")
    end
  end
end
