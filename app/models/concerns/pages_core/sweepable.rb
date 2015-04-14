# encoding: utf-8

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
      return unless PagesCore::CacheSweeper.enabled
      return if cache_swept
      PagesCore::SweepCacheJob.perform_later
      self.cache_swept = true
    end
  end
end
