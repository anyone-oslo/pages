# frozen_string_literal: true

module PagesCore
  class AutopublishJob < ApplicationJob
    queue_as :pages_core

    retry_on StandardError, attempts: 10, wait: :polynomially_longer

    def perform
      Autopublisher.run!
    end
  end
end
