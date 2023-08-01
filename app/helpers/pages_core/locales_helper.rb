# frozen_string_literal: true

module PagesCore
  module LocalesHelper
    def content_locale
      params[:locale] || I18n.default_locale.to_s
    end
  end
end
