# encoding: utf-8

module PagesCore
  module HumanizableParam
    extend ActiveSupport::Concern

    def humanized_param(slug)
      "#{id}-" + slug
        .gsub(/[\[\{]/, "(")
        .gsub(/[\]\}]/, ")")
        .gsub(/[^[[:alnum:]]()\-]+/, "-")
        .gsub(/[\-]{2,}/, "-")
        .gsub(/(^\-|\-$)/, "")
    end
  end
end
