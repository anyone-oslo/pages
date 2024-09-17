# frozen_string_literal: true

module PagesCore
  module PageModel
    module Searchable
      extend ActiveSupport::Concern

      def search_document_attributes
        super.merge(
          published: published? && !skip_index?,
          name:,
          description: try(&:meta_description?) ? meta_description : excerpt,
          # content: "",
          tags: tag_names.join(" ")
        )
      end
    end
  end
end
