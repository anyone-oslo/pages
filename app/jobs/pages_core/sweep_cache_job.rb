# frozen_string_literal: true

module PagesCore
  class SweepCacheJob < ActiveJob::Base
    queue_as :pages_core

    def perform
      PagesCore::CacheSweeper.sweep!
    end
  end
end
