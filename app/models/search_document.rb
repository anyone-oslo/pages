# frozen_string_literal: true

class SearchDocument < ApplicationRecord
  include PgSearch::Model

  belongs_to :searchable, polymorphic: true

  validates :locale, presence: true

  before_validation :configure_dictionary,
                    :inherit_updated_at

  scope :published, -> { where(published: true) }

  pg_search_scope :full_text_search_scope, lambda { |query, dictionary|
    { against: %i[name description content tags],
      using: { tsearch: { prefix: true, dictionary:, tsvector_column: "tsv" } },
      ignoring: :accents,
      order_within_rank: "search_documents.record_updated_at DESC",
      query: }
  }

  pg_search_scope :trigram_search_scope, lambda { |query, dictionary|
    { against: %i[name description content tags],
      using: { tsearch: { prefix: true, dictionary:, tsvector_column: "tsv" },
               trigram: { only: %i[name] } },
      ignoring: :accents,
      order_within_rank: "search_documents.record_updated_at DESC",
      query: }
  }

  class << self
    def results
      select(:searchable_id, :searchable_type, :locale)
        .map(&:localized_searchable)
    end

    def search(query, locale: nil, trigram: false)
      locale ||= I18n.locale
      scope = where(locale:).includes(:searchable)
      if trigram
        scope.trigram_search_scope(query, search_configuration(locale))
      else
        scope.full_text_search_scope(query, search_configuration(locale))
      end
    end

    def search_configuration(locale)
      search_configurations[locale&.to_sym] || "simple_unaccent"
    end

    def search_configurations
      # These are the dictionaries PostgreSQL 12 ships with.
      # Also available in PostgreSQL 13: el: "greek_unaccent",
      { ar: "arabic_unaccent", da: "danish_unaccent", nl: "dutch_unaccent",
        en: "english_unaccent", fi: "finnish_unaccent", fr: "french_unaccent",
        de: "german_unaccent", hu: "hungarian_unaccent",
        id: "indonesian_unaccent", ga: "irish_unaccent", it: "italian_unaccent",
        lt: "lithuanian_unaccent", ne: "nepali_unaccent",
        nb: "norwegian_unaccent", pt: "portuguese_unaccent",
        rm: "romanian_unaccent", ru: "russian_unaccent", es: "spanish_unaccent",
        sv: "swedish_unaccent", ta: "tamil_unaccent", tr: "turkish_unaccent" }
    end
  end

  def localized_searchable
    return searchable unless searchable.respond_to?(:localize)

    searchable.localize(locale)
  end

  private

  def configure_dictionary
    self.tsv_config = self.class.search_configuration(locale)
  end

  def inherit_updated_at
    self.record_updated_at = searchable.updated_at
  end
end
