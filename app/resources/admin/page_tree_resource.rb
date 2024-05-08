# frozen_string_literal: true

module Admin
  class PageTreeResource
    include Alba::Resource

    attributes :id, :parent_page_id, :status, :news_page, :pinned,
               :published_at

    attribute :blocks do
      { name: localized_attribute(object, :name) }
    end

    attribute :permissions do
      [(:edit if Policy.for(params[:user], object).edit?),
       (:create if Policy.for(params[:user], object).edit?)].compact
    end

    private

    def localized_attribute(record, attr)
      record.locales.index_with do |locale|
        record.localize(locale).send(attr)
      end
    end
  end
end
