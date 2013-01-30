# encoding: utf-8

require 'pages_core/templates/block_configuration'
require 'pages_core/templates/configuration'
require 'pages_core/templates/template_configuration'

module PagesCore
  module Templates
    class << self
      def names
        unless (@@available_templates_cached ||= nil)
          templates = [
            PagesCore.plugin_root.join('app', 'views', 'pages', 'templates'),
            Rails.root.join('app', 'views', 'pages', 'templates')
          ].map do |location|
            Dir.entries(location).select{|f| File.file?(File.join(location, f)) and !f.match(/^_/)} if File.exists?(location)
          end
          templates = templates.flatten.uniq.compact.sort.map{|f| f.gsub(/\.[\w\d\.]+$/,'')}

          # Move the index template to the front
          if templates.include?("index")
            templates = ["index", templates.reject{|f| f == "index"}].flatten
          end
          @@available_templates_cached = templates
        end
        return @@available_templates_cached
      end
    end
  end
end
