# encoding: utf-8

module PagesCore
  module PageModel
    module Status
      extend ActiveSupport::Concern

      module ClassMethods
        def status_labels
          {
            0 => "Draft",
            1 => "Reviewed",
            2 => "Published",
            3 => "Hidden",
            4 => "Deleted"
          }
        end
      end

      # Return the status of the page as a string
      def status_label
        self.class.status_labels[status]
      end

      def flag_as_deleted!
        update(status: 4)
      end

      def draft?
        status.zero?
      end

      def reviewed?
        status == 1
      end

      def published?
        status == 2 && !autopublish?
      end

      def hidden?
        status == 3
      end

      def deleted?
        status == 4
      end
    end
  end
end
