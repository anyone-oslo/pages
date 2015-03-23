module PagesCore
  module SearchablePage
    extend ActiveSupport::Concern

    def localization_values
      localizations.map(&:value)
    end

    def category_names
      categories.map(&:name)
    end

    def comment_names
      comments.map(&:name)
    end

    def comment_bodies
      comments.map(&:body)
    end

    def published
      published?
    end
  end
end
