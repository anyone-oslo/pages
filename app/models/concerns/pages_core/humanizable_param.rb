# frozen_string_literal: true

module PagesCore
  module HumanizableParam
    include ActiveSupport::Inflector
    extend ActiveSupport::Concern

    def humanized_param(slug)
      return id.to_s unless slug&.present?

      "#{id}-" + transliterate(slug)
                 .downcase
                 .gsub(/[\[{]/, "(")
                 .gsub(/\}]/, ")")
                 .gsub(/[^[[:alnum:]]()-]+/, "-")
                 .gsub(/-{2,}/, "-")
                 .gsub(/(^-|-$)/, "")
    end
  end
end
