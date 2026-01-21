# frozen_string_literal: true

module PagesCore
  module PageModel
    module Pathable
      extend ActiveSupport::Concern

      included do
        has_many :page_paths, dependent: :destroy

        validates :path_segment, format: { with: /\A[[[:alnum:]]-_]*\z/ }
        validate :path_segment_cannot_be_routable
        before_validation :ensure_no_path_segment_on_deletion
        after_save :ensure_path_segment
        after_save :associate_page_path
      end

      def full_path
        generate_full_path
      end

      def full_path?
        path_segment.present? && pathable?
      end

      def ensure_path_segment
        return if deleted? || path_segment? || generated_path_segment.blank?

        segment = generated_path_segment
        segment = "#{segment}-#{id}" if path_collision?(segment)
        update(path_segment: segment)
      end

      def pathable?
        return true unless parent

        parent.full_path?
      end

      private

      def associate_page_path
        return if deleted? || !full_path?

        PagePath.build(self)
      end

      def ensure_no_path_segment_on_deletion
        return unless deleted?

        self.path_segment = nil
      end

      def generate_full_path(last_segment = nil)
        last_segment ||= path_segment
        return nil unless last_segment.present? && pathable?

        [parent&.full_path, last_segment].compact.join("/")
      end

      def generated_path_segment
        safe_path_segment(transliterated_name).presence ||
          safe_path_segment(unique_name)
      end

      def page_path_matches_routes?(page_path)
        [
          "/#{page_path}",
          "/#{I18n.default_locale}/#{page_path}"
        ].map { |p| recognizable_route?(p) }.any?
      end

      def page_path_route?(route)
        route[:controller] == "pages" &&
          route[:action] == "show" &&
          route[:path].present?
      end

      def path_collision?(path_segment)
        sibling_path_segments.include?(path_segment) ||
          page_path_matches_routes?(generate_full_path(path_segment))
      end

      def path_segment_cannot_be_routable
        return unless full_path?
        return unless page_path_matches_routes?(full_path)

        errors.add(:path_segment, "can't match an existing URL")
      end

      def recognizable_route?(path)
        route = Rails.application.routes.recognize_path(path)
        !page_path_route?(route)
      rescue ActionController::RoutingError
        false
      end

      def safe_path_segment(str)
        str.to_s
           .gsub(/[^[[:alnum:]]-_]+/, "-")
           .gsub(/-{2,}/, "-")
           .gsub(/(^-|-$)/, "")
           .downcase
      end

      def sibling_path_segments
        siblings = if parent
                     parent.children
                   else
                     self.class.roots
                   end
        siblings.reject { |p| p == self }
                .map { |p| p.localize(locale) }
                .map(&:path_segment)
                .compact_blank
      end
    end
  end
end
