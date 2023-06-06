# frozen_string_literal: true

require "tty-table"

namespace :pages do
  namespace :reports do
    desc "Template usage report"
    task templates: :environment do
      pastel = Pastel.new
      files = PagesCore::Templates.names
      rows = (Page.pluck(:template).to_a + files).uniq.sort.map do |t|
        [t,
         Page.published.where(template: t).count,
         Page.where(template: t).count,
         files.include?(t) ? pastel.green("Yes") : pastel.red("No")]
      end

      table = TTY::Table.new(
        %w[Name Published Total File],
        rows
      )
      puts table.render(:unicode, padding: [0, 1, 0, 1])
      puts "  Total: #{rows.length} templates"
    end
  end
end
