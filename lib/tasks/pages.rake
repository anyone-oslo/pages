require "find"
require "open-uri"

namespace :pages do
  namespace :error_reports do
    desc "Show error reports"
    task list: :environment do
      require "term/ansicolor"
      include Term::ANSIColor

      reports = []
      reports_dir = Rails.root.join("log", "error_reports")
      if File.exist?(reports_dir)
        files = Dir.entries(reports_dir).select { |f| f =~ /\.yml$/ }
        files.each do |f|
          report = begin
                     YAML
                       .load_file(File.join(reports_dir, f))
                       .merge(sha1_hash: f.gsub(/\.yml$/, ""))
                   rescue
                     nil
                   end
          reports << report if report
        end
      end
      if reports.length > 1
        puts
        reports = reports.sort_by { |a| a[:timestamp] }
        reports.each do |report|
          message = report[:message].strip.split("\n").first
          print "#{report[:timestamp]} "
          print (report[:sha1_hash]).to_s.blue.bold, "\n"
          print (report[:url]).to_s.green.bold, "\n"
          print "#{report[:params].inspect}\n".yellow
          print "#{message}\n\n"
        end
      else
        puts "No error reports found"
      end
    end

    desc "Clear all error reports"
    task clear: :environment do
      reports_dir = Rails.root.join("log", "error_reports")
      if File.exist?(reports_dir)
        files = Dir.entries(reports_dir).select { |f| f =~ /\.yml$/ }
        files.each do |f|
          `rm #{File.join(reports_dir, f)}`
        end
      end
      puts "Error reports cleared"
    end
  end

  desc "Show error reports"
  task error_reports: "pages:error_reports:list" do
  end

  desc "Autopublish due pages"
  task autopublish: :environment do
    published = Autopublisher.run!
    Rails.logger.info "Autopublished #{published.length} pages"
  end

  desc "Perform routine maintenance"
  task maintenance: [:autopublish] do
  end
end
