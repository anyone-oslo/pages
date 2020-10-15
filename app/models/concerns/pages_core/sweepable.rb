# frozen_string_literal: true

module PagesCore
  module Sweepable
    extend ActiveSupport::Concern

    included do
      after_save :sweep_cache!
      after_destroy :sweep_cache!
    end

    attr_accessor :cache_swept

    protected

    def sweep_cache!
      return if cache_swept

      PagesCore::StaticCache.handler.sweep!
      self.cache_swept = true
    end
  end
end
