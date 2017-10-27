module PagesCore
  module PageModel
    module Autopublishable
      extend ActiveSupport::Concern

      included do
        before_validation :set_autopublish
        after_save :queue_autopublisher
      end

      private

      def set_autopublish
        self.autopublish = published_at? && published_at > Time.now.utc
        true
      end

      def queue_autopublisher
        Autopublisher.queue! if autopublish?
      end
    end
  end
end
