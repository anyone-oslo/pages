# frozen_string_literal: true

namespace :pages do
  namespace :cache do
    desc "Sweep the pages cache"
    task sweep: :environment do
      PagesCore::StaticCache.handler.sweep_now!
      Rails.logger.info "Static cache swept"
    end

    desc "Sweep the pages cache (queued)"
    task sweep_later: :environment do
      PagesCore::StaticCache.handler.sweep!
      Rails.logger.info "Static cache sweeping queued"
    end

    desc "Purge the entire pages cache"
    task purge: :environment do
      PagesCore::StaticCache.handler.purge!
      Rails.logger.info "Cache purged"
    end
  end
end
