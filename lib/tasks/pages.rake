require "find"
require "open-uri"

namespace :pages do
  desc "Autopublish due pages"
  task autopublish: :environment do
    published = Autopublisher.run!
    Rails.logger.info "Autopublished #{published.length} pages"
  end

  desc "Convert templates"
  task convert_templates: :environment do
    TemplateConverter.convert!
  end

  desc "Perform routine maintenance"
  task maintenance: [:autopublish] do
  end
end
