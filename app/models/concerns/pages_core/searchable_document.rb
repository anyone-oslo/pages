# frozen_string_literal: true

module PagesCore
  module SearchableDocument
    extend ActiveSupport::Concern

    included do
      has_many :search_documents, as: :searchable, dependent: :destroy
      after_save :update_search_documents!
    end

    class Indexer
      attr_reader :record

      def initialize(record)
        @record = record
      end

      def index!
        SearchDocument.transaction do
          record.search_documents.where.not(locale: locales).destroy_all
          locales.each do |locale|
            update_index(
              locale,
              localized_record(locale).search_document_attributes
            )
          end
        end
      end

      private

      def locales
        if record.respond_to?(:locales)
          record.locales
        elsif PagesCore.config.locales
          PagesCore.config.locales.keys
        else
          [I18n.default_locale]
        end
      end

      def localized_record(locale)
        return record unless record.respond_to?(:localize)

        record.localize(locale)
      end

      def update_index(locale, attrs)
        record.search_documents.create_or_find_by!(locale: locale).update(attrs)
      end
    end

    def search_document_attributes
      return {} unless respond_to?(:localized_attributes)

      content = localized_attributes.keys.map { |a| localizer.get(a) }.join(" ")
      { content: content }
    end

    def update_search_documents!
      PagesCore::SearchableDocument::Indexer.new(self).index!
    end
  end
end
