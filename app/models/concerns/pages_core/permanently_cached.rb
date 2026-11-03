# frozen_string_literal: true

module PagesCore
  module PermanentlyCached
    extend ActiveSupport::Concern

    included do
      after_commit :purge_permanent_cache,
                   on: %i[update destroy],
                   if: -> { destroyed? || saved_change_to_content_hash? }
    end

    def cache_tag
      "#{model_name.singular}-#{id}"
    end

    private

    def purge_permanent_cache
      PagesCore::StaticCache.handler.purge_record!(self)
    end
  end
end
