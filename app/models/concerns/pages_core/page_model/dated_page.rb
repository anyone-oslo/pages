module PagesCore
  module PageModel
    module DatedPage
      extend ActiveSupport::Concern

      included do
        before_validation :set_all_day_dates
        before_validation :ensure_ends_at

        scope :upcoming, -> { where("ends_at > ?", Time.zone.now) }
      end

      module ClassMethods
      end

      def upcoming?
        return false unless ends_at?
        ends_at > Time.zone.now
      end

      private

      def ensure_ends_at
        return unless starts_at?
        self.ends_at = starts_at if !ends_at? || ends_at < starts_at
      end

      def set_all_day_dates
        return unless all_day?
        self.starts_at = starts_at.beginning_of_day if starts_at?
        self.ends_at = ends_at.end_of_day if ends_at?
      end
    end
  end
end
