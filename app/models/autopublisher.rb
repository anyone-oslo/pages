# frozen_string_literal: true

class Autopublisher
  class << self
    def run!
      if due_pages.any?
        PagesCore::CacheSweeper.once do
          due_pages.each do |p|
            p.update(autopublish: false)
          end
        end
      end
      queue!
    end

    def queue!
      return unless queued_pages.any?

      PagesCore::AutopublishJob
        .set(wait_until: queued_pages.first.published_at)
        .perform_later
    end

    protected

    def queued_pages
      Page.where(autopublish: true)
          .order("published_at ASC")
          .in_locale(I18n.default_locale)
    end

    def due_pages
      queued_pages.where(published_at: ...(Time.now.utc + 2.minutes))
    end
  end
end
