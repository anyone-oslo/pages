# frozen_string_literal: true

module PagesCore
  class AutopublishJob < ApplicationJob
    queue_as :pages_core

    def perform
      Autopublisher.run!
    end
  end
end
