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
      if PagesCore::CacheSweeper.enabled
        if !self.cache_swept
          PagesCore::CacheSweeper.sweep_image!(self) if self.kind_of?(Image)
          PagesCore::CacheSweeper.send_later(:sweep!)
          self.cache_swept = true
        end
      end
    end
  end
end