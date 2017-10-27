module PagesCore
  module HumanizableParam
    extend ActiveSupport::Concern

    def humanized_param(slug)
      return id.to_s unless slug && slug.present?
      "#{id}-" + slug
                 .gsub(/[\[\{]/, "(")
                 .gsub(/[\]\}]/, ")")
                 .gsub(/[^[[:alnum:]]()\-]+/, "-")
                 .gsub(/[\-]{2,}/, "-")
                 .gsub(/(^\-|\-$)/, "")
    end
  end
end
