# frozen_string_literal: true

require "find"
require "open-uri"

namespace :pages do
  desc "Autopublish due pages"
  task autopublish: :environment do
    published = Autopublisher.run!
    Rails.logger.info "Autopublished #{published.length} pages"
  end

  desc "Perform routine maintenance"
  task maintenance: [:autopublish]
end
