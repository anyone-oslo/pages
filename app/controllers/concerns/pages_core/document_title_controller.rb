# frozen_string_literal: true

module PagesCore
  module DocumentTitleController
    extend ActiveSupport::Concern

    included do
      helper_method :document_title
    end

    def document_title(*args)
      @document_title = args.first if args.any?
      @document_title
    end
  end
end
