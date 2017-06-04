# encoding: utf-8

module PagesCore
  module PageModel
    module Searchable
      extend ActiveSupport::Concern

      included do
        if const_defined?("ThinkingSphinx")
          after_save ThinkingSphinx::RealTime.callback_for(:page)
        end
      end

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

      def file_names
        files.map(&:name)
      end

      def file_filenames
        files.map(&:filename)
      end

      def published
        published?
      end
    end
  end
end
