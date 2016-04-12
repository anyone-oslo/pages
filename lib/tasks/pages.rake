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
    puts "Templates converted. Remember to move any template actions " \
         "from PagesController to the template files."
  end

  desc "Perform routine maintenance"
  task maintenance: [:autopublish] do
  end
end
