module PagesCore
  class AutopublishJob < ActiveJob::Base
    queue_as :pages_core

    def perform
      Autopublisher.run!
    end
  end
end
