namespace :pages do
  namespace :export do
    desc "Export pages"
    task pages: :environment do
      dir = Rails.root.join("export")
      PageExporter.new(dir).export
    end
  end
end
