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
    config_file = Rails.root.join("config", "initializers", "page_templates.rb")
    TemplateConverter.convert!
    puts "Templates converted. Remember to move any template actions " \
         "from PagesController to the template files."
    if File.exist?(config_file)
      FileUtils.rm(config_file)
    else
      puts "Could not find template initializer, please remove the old " \
           "configuration from config/initializers/pages.rb"
    end
  end

  desc "Perform routine maintenance"
  task maintenance: [:autopublish] do
  end
end
