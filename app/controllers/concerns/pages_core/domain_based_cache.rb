# encoding: utf-8

module PagesCore
  module DomainBasedCache
    extend ActiveSupport::Concern

    included do
      before_action :set_domain_based_cache_path
    end

    module ClassMethods
      def default_page_cache_directory
        @@default_page_cache_directory ||= ActionController::Base.page_cache_directory
      end
    end

    protected

    def set_domain_based_cache_path
      if PagesCore.config(:domain_based_cache)
        path = File.join(ApplicationController.default_page_cache_directory, request.domain)
        ActionController::Base.page_cache_directory = path
      end
    end
  end
end