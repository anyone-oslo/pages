# frozen_string_literal: true

module PagesCore
  module PageModel
    module Attachments
      extend ActiveSupport::Concern

      included do
        has_many :page_files,
                 -> { order(:position) },
                 class_name: "PageFile",
                 dependent: :destroy,
                 inverse_of: :page

        has_many :attachments, through: :page_files

        accepts_nested_attributes_for(
          :page_files,
          reject_if: proc { |a| a["attachment_id"].blank? },
          allow_destroy: true
        )
      end

      def attachments
        super.in_locale(locale)
      end

      def attachments?
        attachments.any?
      end

      def page_files
        super.in_locale(locale)
      end

      def page_files_attributes=(attrs)
        ids = page_files.map(&:id)
        super(attrs.reject { |a| a["_destroy"] && ids.exclude?(a["id"]) })
      end

      def files
        page_files
      end
    end
  end
end
