# encoding: utf-8

class Autopublisher
  class << self

    def run!(options={})
      if due_pages.any?
        PagesCore::CacheSweeper.once do
          due_pages.each do |p|
            p.update(autopublish: false)
          end
        end
      end
      self.queue!
    end

    def queue!
      if queued_pages.any?
        self.delay(run_at: queued_pages.first.published_at).run!
      end
    end

    protected

    def queued_pages
      Page.where(autopublish: true).order('published_at ASC')
    end

    def due_pages
      queued_pages.where('published_at < ?', (Time.now + 2.minutes))
    end
  end
end