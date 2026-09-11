# frozen_string_literal: true

module Admin
  # WYSIWYG spike: Textile → HTML for the document editor. Nothing is written.
  class DocumentConversionsController < Admin::AdminController
    def create
      render json: PagesCore::DocumentConverter.convert(params.expect(:text))
    end
  end
end
