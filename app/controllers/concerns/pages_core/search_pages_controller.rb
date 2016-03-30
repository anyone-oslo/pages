# encoding: utf-8

module PagesCore
  module SearchPagesController
    extend ActiveSupport::Concern

    def search
      @search_query = params[:q] || params[:query] || ""
      @search_category_id = params[:category_id]

      @pages = Page.search(
        normalize_search_query(@search_query),
        search_options(category_id: @search_category_id)
      )
      @pages.each { |p| p.localize!(locale) }
      @pages
    end

    private

    def normalize_search_query(str)
      str.split(/\s+/)
         .map { |p| "#{p}*" }
         .join(" ")
    end

    def search_options(category_id: nil)
      options = {
        page:      (params[:page] || 1).to_i,
        per_page:  20,
        include:   [:localizations, :categories, :image, :author],
        order:     :published_at,
        sort_mode: :desc,
        with:      { status: 2, autopublish: 0 }
      }
      options[:with][:category_ids] = category_id unless category_id.blank?
      options
    end
  end
end
