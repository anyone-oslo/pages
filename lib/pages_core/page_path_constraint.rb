# encoding: utf-8

module PagesCore
  class PagePathConstraint
    def matches?(request)
      locale?(request.path_parameters[:locale]) &&
        exists?(
          request.path_parameters[:locale],
          request.path_parameters[:path]
        )
    end

    private

    def locale?(str)
      str.to_s =~ /\A[a-z]{2}\z/
    end

    def exists?(locale, path)
      PagePath.get(locale, path) ? true : false
    end
  end
end
