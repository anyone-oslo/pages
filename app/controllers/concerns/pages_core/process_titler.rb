# encoding: utf-8

module PagesCore
  module ProcessTitler
    extend ActiveSupport::Concern

    included do
      before_action :set_process_title
      after_action  :unset_process_title
    end

    protected

    def set_process_title
      @@default_process_title ||= $0
      @@number_of_requests ||= 0
      @@number_of_requests += 1
      $0 = "#{@@default_process_title}: Handling #{request.path} (#{@@number_of_requests} reqs)"
    end

    def unset_process_title
      set_process_title
      $0 = "#{@@default_process_title}: Idle (#{@@number_of_requests} reqs)"
    end
  end
end