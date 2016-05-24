# encoding: utf-8

require "pages_core/templates/block_configuration"
require "pages_core/templates/configuration_proxy"
require "pages_core/templates/configuration_handler"
require "pages_core/templates/configuration"
require "pages_core/templates/controller_actions"
require "pages_core/templates/template_configuration"

module PagesCore
  module Templates
    class << self
      def names
        @names ||= find_all_templates
      end

      private

      def template_paths
        [
          PagesCore.plugin_root.join("app", "views", "pages", "templates"),
          Rails.root.join("app", "views", "pages", "templates")
        ]
      end

      def template_files
        template_paths
          .select { |dir| File.exist?(dir) }
          .flat_map { |dir| template_files_in_dir(dir) }
          .uniq
          .compact
          .sort
          .map { |f| f.gsub(/\.[\w\.]+$/, "") }
      end

      def template_files_in_dir(dir)
        Dir.entries(dir).select { |f| template_file?(f, dir) }
      end

      def template_file?(file, dir)
        File.file?(File.join(dir, file)) && !file.match(/^_/)
      end

      def find_all_templates
        if template_files.include?("index")
          ["index"] + (template_files - ["index"])
        else
          template_files
        end
      end
    end
  end
end
