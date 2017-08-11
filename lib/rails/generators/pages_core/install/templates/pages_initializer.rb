# encoding: utf-8

# Be sure to restart your web server when you modify this file.

PagesCore.configure do |config|
  # Site name and default mail sender
  config.site_name "<%= @site_name %>"
  config.default_sender "<%= @default_sender %>"

  # Localizations (default: disabled)
  # config.localizations :disabled

  # Locales and names
  # config.locales(nb: 'Norwegian', en: 'English')

  # Page cache (default: enabled)
  # config.page_cache :enabled

  # Domain based page cache (default: disabled)
  # config.domain_based_cache :disabled

  # Fulltext in RSS feeds (default: disabled)
  # config.rss_fulltext :disabled

  # New pages will be created by the user with this email address:
  # config.default_author "email@example.com"

  # Handle exceptions
  # config.exception_handler :enabled

  # Layout for 404 errors
  # config.error_404_layout "errors"

  # Custom file embedder
  # config.file_embedder PagesCore::FileEmbedder
end
