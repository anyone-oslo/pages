# frozen_string_literal: true

# Be sure to restart your web server when you modify this file.

PagesCore.configure do |config|
  # Site name and default mail sender
  config.site_name "<%= @site_name %>"
  config.default_sender "<%= @default_sender %>"

  # Localizations (default: disabled)
  # config.localizations :disabled

  # Locales and names
  # config.locales(nb: 'Norwegian', en: 'English')

  # Fulltext in RSS feeds (default: disabled)
  # config.rss_fulltext :disabled

  # New pages will be created by the user with this email address:
  # config.default_author "email@example.com"

  # Layout for 404 errors
  # config.error_404_layout "errors"

  # Custom attachment embedder
  # config.attachment_embedder PagesCore::AttachmentEmbedder
end
