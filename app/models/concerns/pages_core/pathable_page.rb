# encoding: utf-8

module PagesCore
  module PathablePage
    extend ActiveSupport::Concern

    included do
      validates :path_segment, format: { with: /\A[[[:alnum:]]\-_]*\z/ }
      before_validation :ensure_no_path_segment_on_deletion
      after_save :ensure_path_segment
    end

    def full_path
      return nil unless full_path?
      self_and_ancestors
        .reverse
        .map(&:path_segment)
        .join("/")
    end

    def full_path?
      !self_and_ancestors.select { |p| !p.path_segment? }.any?
    end

    private

    def ensure_no_path_segment_on_deletion
      return unless deleted?
      self.path_segment = nil
    end

    def ensure_path_segment
      return if deleted? || path_segment? || !name?
      if sibling_path_segments.include?(generated_path_segment)
        update path_segment: "#{generated_path_segment}-#{id}"
      else
        update path_segment: generated_path_segment
      end
    end

    def generated_path_segment
      name
        .gsub(/[^[[:alnum:]]\-_]+/, "-")
        .gsub(/[\-]{2,}/, "-")
        .gsub(/(^\-|\-$)/, "")
        .mb_chars
        .downcase
    end

    def sibling_path_segments
      siblings = if parent
                   parent.children
                 else
                   self.class.roots
                 end
      siblings
        .reject { |p| p == self }
        .map { |p| p.localize(locale) }
        .map(&:path_segment)
        .reject(&:blank?)
    end
  end
end
