# frozen_string_literal: true

module PagesCore
  module HumanizableParam
    include ActiveSupport::Inflector
    extend ActiveSupport::Concern

    def humanized_param(slug)
      safe_slug = safe_humanized_param(slug)
      return id.to_s if safe_slug.blank?

      "#{id}-#{safe_slug}"
    end

    private

    def safe_humanized_param(str)
      transliterate(str.to_s).downcase
                             .gsub(/[\[{]/, "(")
                             .gsub(/}\]/, ")")
                             .gsub(/[^[[:alnum:]]()-]+/, "-")
                             .gsub(/-{2,}/, "-")
                             .gsub(/(^-|-$)/, "")
    end
  end
end
