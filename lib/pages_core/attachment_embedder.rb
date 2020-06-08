# frozen_string_literal: true

module PagesCore
  class AttachmentEmbedder
    include ActionView::Helpers::AssetTagHelper

    attr_reader :attachments

    def initialize(attachments)
      @attachments = Array(attachments)
    end

    def to_html
      embed_attachments(attachments.map { |f| embed_attachment(f) })
    end

    def embed_attachments(embedded_attachments)
      embedded_attachments.join(", ")
    end

    def embed_attachment(attachment)
      content_tag(
        :a,
        attachment.name,
        class: "file",
        href: attachment_path(attachment)
      )
    end

    private

    def attachment_path(attachment)
      Rails.application.routes.url_helpers.attachment_path(
        attachment.digest,
        attachment,
        format: attachment.filename_extension
      )
    end
  end
end
