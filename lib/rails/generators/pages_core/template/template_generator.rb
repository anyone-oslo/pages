module PagesCore
  module Generators
    class TemplateGenerator < Rails::Generators::NamedBase
      desc "Generates a template"
      source_root File.expand_path("../templates", __FILE__)

      argument(:blocks,
               type: :array,
               default: [],
               banner: "block[:size] block[:size]")

      check_class_collision

      class_option(:enabled_blocks,
                   type: :string,
                   desc: "Enabled blocks, comma separated")

      class_option(:parent,
                   type: :string,
                   desc: "The parent class for the generated model")

      class_option(:subtemplate,
                   type: :string,
                   desc: "Subtemplate")

      class_option(:view_name,
                   type: :string,
                   desc: "Filename for template file")

      class_option(:view,
                   type: :boolean,
                   default: true,
                   desc: "Create view")

      class_option(:comments,
                   type: :boolean,
                   desc: "Enable comments")

      class_option(:comments_allowed,
                   type: :boolean,
                   desc: "Allow comments")

      class_option(:files,
                   type: :boolean,
                   desc: "Enable files")

      class_option(:images,
                   type: :boolean,
                   desc: "Enable images")

      class_option(:tags,
                   type: :boolean,
                   desc: "Enable tags")

      def create_template
        template("template.erb",
                 File.join("app/templates",
                           class_path,
                           "#{file_name}_template.rb"))
      end

      def create_view
        return unless options[:view]
        copy_file("view.html.erb",
                  File.join("app/views/pages/templates",
                            class_path,
                            "#{file_name}.html.erb"))
      end

      protected

      def blocks_with_size
        blocks.map { |s| s.split(":") }
      end

      def class_name
        super + "Template"
      end

      def default_subtemplate
        file_name
      end

      def enabled_blocks
        return nil if options[:enabled_blocks].blank?
        options[:enabled_blocks].split(",").map(&:strip)
      end

      def parent_class_name
        options[:parent] || "ApplicationTemplate"
      end

      def subtemplate
        options[:subtemplate] || default_subtemplate
      end

      def view_name
        options[:view_name] || file_name
      end
    end
  end
end
