module PagesCore
  module PageModel
    module Pathable
      extend ActiveSupport::Concern

      included do
        has_many :page_paths, dependent: :destroy

        validates :path_segment, format: { with: /\A[[[:alnum:]]\-_]*\z/ }
        validate :path_segment_cannot_be_routable
        before_validation :ensure_no_path_segment_on_deletion
        after_save :ensure_path_segment
        after_save :associate_page_path
      end

      def full_path(last_segment = nil)
        last_segment ||= path_segment
        return nil unless full_path?(last_segment)
        if parent
          [parent.full_path, last_segment].join("/")
        else
          last_segment
        end
      end

      def full_path?(last_segment = nil)
        last_segment ||= path_segment
        if parent
          parent.full_path? && last_segment.present?
        else
          last_segment.present?
        end
      end

      def ensure_path_segment
        return if deleted? || !name?

        if path_segment? && path_segment != previous_generated_path_segment
          return
        end

        if path_collision?(generated_path_segment)
          update path_segment: "#{generated_path_segment}-#{id}"
        else
          update path_segment: generated_path_segment
        end
      end

      def name=(new_name)
        @previous_name = name
        super
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

      def generated_path_segment
        str_to_path_segment(transliterated_name)
      end

      def str_to_path_segment(str)
        str.gsub(/[^[[:alnum:]]\-_]+/, "-")
           .gsub(/[\-]{2,}/, "-")
           .gsub(/(^\-|\-$)/, "")
           .mb_chars
           .downcase
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
          page_path_matches_routes?(full_path(path_segment))
      end

      def path_segment_cannot_be_routable
        return unless full_path?
        return unless page_path_matches_routes?(full_path)

        errors.add(:path_segment, "can't match an existing URL")
      end

      def previous_generated_path_segment
        return nil if @previous_name.blank?

        str_to_path_segment(transliterate_value(@previous_name))
      end

      def recognizable_route?(path)
        route = Rails.application.routes.recognize_path(path)
        !page_path_route?(route)
      rescue ActionController::RoutingError
        false
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
                .reject(&:blank?)
      end
    end
  end
end
