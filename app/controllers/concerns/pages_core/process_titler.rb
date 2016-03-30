# encoding: utf-8

module PagesCore
  module ProcessTitler
    extend ActiveSupport::Concern

    included do
      before_action :set_process_title
      after_action :unset_process_title
    end

    class << self
      attr_accessor :number_of_requests

      def original_title
        @original_title ||= $PROGRAM_NAME
      end

      def inc_number_of_requests
        @number_of_requests ||= 0
        @number_of_requests += 1
        yield @number_of_requests
      end

      def number_of_requests
        @number_of_requests ||= 0
      end
    end

    protected

    def set_process_title
      PagesCore::ProcessTitler.inc_number_of_requests do |i|
        $0 = PagesCore::ProcessTitler.original_title +
             ": Handling #{request.path} (#{i} reqs)"
      end
    end

    def unset_process_title
      $0 = PagesCore::ProcessTitler.original_title +
           ": Idle (#{PagesCore::ProcessTitler.number_of_requests} reqs)"
    end
  end
end
