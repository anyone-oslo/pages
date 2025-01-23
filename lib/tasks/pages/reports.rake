# frozen_string_literal: true

require "tty-table"

namespace :pages do
  namespace :reports do
    desc "External content"
    task external_content: :environment do
      rows = []

      Page.order("id ASC").includes(:localizations).find_each do |page|
        scanner = PagesCore::ExternalContentScanner.new(page)
        next unless scanner.results.any?

        scanner.results.each do |r|
          rows << [page.id, r[:name], r[:locale], r[:type],
                   r[:url].truncate(80)]
        end
      end

      table = TTY::Table.new(%w[PageID Block Locale Type URL], rows)
      puts table.render(:unicode, padding: [0, 1, 0, 1])
      puts "  Total: #{rows.length} elements"
    end

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
