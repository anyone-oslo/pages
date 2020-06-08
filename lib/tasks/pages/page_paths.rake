# frozen_string_literal: true

namespace :pages do
  namespace :page_paths do
    desc "Build page paths"
    task build: :environment do
      print "Building page paths..."
      PagePath.build_all
      puts "Done!"
    end
  end
end
