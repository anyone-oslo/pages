# encoding: utf-8

module PagesCore
  module HumanizableParam
    extend ActiveSupport::Concern

    def humanized_param(slug)
      slug = slug.gsub(/[\[\{]/,'(')
      slug = slug.gsub(/[\]\}]/,')')
      slug = slug.gsub(/[^[[:alnum:]]()\-]+/,'-').gsub(/[\-]{2,}/,'-').gsub(/(^\-|\-$)/,'')
      "#{self.id.to_s}-" + slug
    end
  end
end