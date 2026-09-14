# frozen_string_literal: true

module Admin
  # Spike: Textile → HTML for the editor. Does not persist; page save does.
  class DocumentConversionsController < Admin::AdminController
    def create
      render json: PagesCore::DocumentConverter.convert(params.expect(:text))
    end
  end
end
