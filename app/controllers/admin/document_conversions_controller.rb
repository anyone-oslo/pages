# frozen_string_literal: true

module Admin
  # Rich text editor spike: Textile → HTML for the editor. Nothing is written.
  class DocumentConversionsController < Admin::AdminController
    def create
      render json: PagesCore::DocumentConverter.convert(params.expect(:text))
    end
  end
end
