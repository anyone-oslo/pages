# frozen_string_literal: true

namespace :pages do
  namespace :export do
    desc "Export pages"
    task pages: :environment do
      dir = Rails.root.join("export")
      PageExporter.new(dir, progress_bar: true).export
    end
  end
end
