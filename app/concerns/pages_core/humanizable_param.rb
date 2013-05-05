module PagesCore
  module HumanizableParam
    extend ActiveSupport::Concern

    def humanized_param(slug)
      "#{id}-" + slug.downcase.gsub(/[^\w\s]/, '').split(/[^\w\d\-]+/).compact.join( "_" )
    end

    # This is the version from Sugar
    # TODO: Switch to this
    # def humanized_param(slug)
    #   slug = slug.gsub(/[\[\{]/,'(')
    #   slug = slug.gsub(/[\]\}]/,')')
    #   slug = slug.gsub(/[^\w\d!$&'()*,;=\-]+/,'-').gsub(/[\-]{2,}/,'-').gsub(/(^\-|\-$)/,'')
    #   "#{self.id.to_s};" + slug
    # end
  end
end