# encoding: utf-8

require "find"
require "open-uri"
require "fileutils"
require "pathname"

namespace :pages do
  namespace :assets do
    namespace :update do
      desc "Updates jQuery"
      task jquery: :environment do
        puts "* Updating jQuery..."
        output = open("http://code.jquery.com/jquery.min.js").read
        File.open("app/assets/javascripts/jquery.js", "w") do |fh|
          fh.write output
        end
      end

      desc "Updates legacy assets"
      task :legacy do
        if File.exist?("public/plugin_assets")
          puts "* Removing old plugin assets"
          FileUtils.rm_rf "public/plugin_assets"
        end
        if File.exist?("public/javascripts")
          puts "* Removing old javascripts"
          FileUtils.rm_rf "public/javascripts"
        end
        if File.exist?("public/stylesheets")
          puts "* Removing old stylesheets"
          FileUtils.rm_rf "public/stylesheets"
        end

        Find.find("app/assets") do |path|
          next unless path =~ /\.coffee$/ && !(path =~ /\.js\.coffee$/)
          new_path = path.gsub(/\.coffee$/, ".js.coffee")
          puts "#{path} => #{new_path}"
          FileUtils.mv(path, new_path)
        end

        Find.find("app/assets") do |path|
          next unless path =~ /\.scss$/ && !(path =~ /\.css\.scss$/)
          new_path = path.gsub(/\.scss$/, ".css.scss")
          puts "#{path} => #{new_path}"
          FileUtils.mv(path, new_path)
        end
      end
    end

    desc "Update all assets"
    task update: ["update:jquery"] do
    end

    desc "Update to SCSS"
    task convert_to_scss: :environment do
      assets_dir = Rails.root.join("app", "assets", "stylesheets")
      Find.find(assets_dir) do |path|
        next unless path =~ /\.css$/
        scss_path = path.gsub(/\.css$/, ".css.scss")
        `git mv #{path} #{scss_path}`
      end
    end
  end
end
