# frozen_string_literal: true

require "pages_core/attachment_embedder"

module PagesCore
  module Configuration
    class Pages < Base
      setting :site_name,             :string, "Pages Site"
      setting :default_sender,        :string
      setting :localizations,         :boolean, false
      setting :locales,               :hash
      setting :text_filter,           :symbol, :textile
      setting :page_cache,            :boolean, true
      setting :domain_based_cache,    :boolean, false
      setting :rss_fulltext,          :boolean, true
      setting :image_fallback_url,    :string
      setting :default_author,        :string
      setting :error_404_layout,      :string
      setting :attachment_embedder,   :object, PagesCore::AttachmentEmbedder
    end
  end
end
