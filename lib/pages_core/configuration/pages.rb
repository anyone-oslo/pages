# frozen_string_literal: true

require "pages_core/attachment_embedder"
require "pages_core/static_cache"

module PagesCore
  module Configuration
    class Pages < Base
      setting :site_name,             :string, "Pages Site"
      setting :default_sender,        :string
      setting :localizations,         :boolean, false
      setting :locales,               :hash
      setting :text_filter,           :symbol, :textile
      setting :image_fallback_url,    :string
      setting :default_author,        :string
      setting :error_404_layout,      :string
      setting :attachment_embedder,   :object, PagesCore::AttachmentEmbedder
      setting :static_cache_handler,  :object
    end
  end
end
