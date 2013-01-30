# encoding: utf-8

require 'find'
require 'open-uri'

begin
  require 'delayed/tasks'
rescue LoadError
  puts "Delayed job not installed"
end

begin
  require 'thinking_sphinx/tasks'
rescue LoadError
  puts "You can't load Thinking Sphinx tasks unless the thinking-sphinx gem is installed."
end

namespace :pages do

  namespace :error_reports do
    desc "Show error reports"
    task :list => :environment do
      require 'term/ansicolor'
      include Term::ANSIColor

      reports = []
      reports_dir = Rails.root.join('log', 'error_reports')
      if File.exists?(reports_dir)
        files = Dir.entries(reports_dir).select{|f| f =~ /\.yml$/}
        files.each do |f|
          if report = YAML.load_file(File.join(reports_dir, f)).merge({:sha1_hash => f.gsub(/\.yml$/, '')}) rescue nil
            reports << report
          end
        end
      end
      if reports.length > 1
        puts
        reports = reports.sort{|a, b| a[:timestamp] <=> b[:timestamp]}
        reports.each do |report|
          message = report[:message].strip.split("\n").first
          print "#{report[:timestamp]} ", "#{report[:sha1_hash]}".blue.bold, "\n"
          print "#{report[:url]}".green.bold, "\n"
          print "#{report[:params].inspect}\n".yellow
          print "#{message}\n\n"
        end
      else
        puts "No error reports found"
      end
    end

    desc "Clear all error reports"
    task :clear => :environment do
      reports_dir = Rails.root.join('log', 'error_reports')
      if File.exists?(reports_dir)
        files = Dir.entries(reports_dir).select{|f| f =~ /\.yml$/}
        files.each do |f|
          `rm #{File.join(reports_dir, f)}`
        end
      end
      puts "Error reports cleared"
    end
  end

  desc "Show error reports"
  task :error_reports => "pages:error_reports:list" do
  end

  desc "Deliver mailing queue"
  task :deliver_mailings => :environment do
    Rails.logger.info "Delivering mailings"
    Mailing.do_queue
  end

  desc "Refresh RSS feeds"
  task :refresh_feeds => :environment do
    Rails.logger.info "Refreshing external feeds"
    PagesCore::CacheSweeper.once do
      Feed.find(:all).each do |feed|
        begin
          feed.refresh
        rescue
          Rails.logger.warn "!!! Error parsing feed #{feed.url} - #{$!.to_s}"
        end
      end
    end
  end

  desc "Autopublish due pages"
  task :autopublish => :environment do
    published = Page.autopublish!
    Rails.logger.info "Autopublished #{published.length} pages"
  end

  desc "Perform routine maintenance"
  task :maintenance => [:autopublish, :clean_sessions, :refresh_feeds, :deliver_mailings] do
  end

end
