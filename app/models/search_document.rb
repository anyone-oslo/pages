# frozen_string_literal: true

class SearchDocument < ApplicationRecord
  belongs_to :searchable, polymorphic: true

  validates :locale, presence: true

  before_validation :configure_dictionary

  class << self
    def search_configuration(locale)
      search_configurations[locale.to_sym] || "simple_unaccent"
    end

    def search_configurations
      # These are the dictionaries PostgreSQL ships with
      { ar: "arabic_unaccent", da: "danish_unaccent", nl: "dutch_unaccent",
        en: "english_unaccent", fi: "finnish_unaccent", fr: "french_unaccent",
        de: "german_unaccent", el: "greek_unaccent", hu: "hungarian_unaccent",
        id: "indonesian_unaccent", ga: "irish_unaccent", it: "italian_unaccent",
        lt: "lithuanian_unaccent", ne: "nepali_unaccent",
        nb: "norwegian_unaccent", pt: "portuguese_unaccent",
        rm: "romanian_unaccent", ru: "russian_unaccent", es: "spanish_unaccent",
        sv: "swedish_unaccent", ta: "tamil_unaccent", tr: "turkish_unaccent" }
    end
  end

  private

  def configure_dictionary
    self.tsv_config = self.class.search_configuration(locale)
  end
end
