module PagesCore
  module Generators
    class TemplateGenerator < Rails::Generators::NamedBase
      desc "Generates a template"
      source_root File.expand_path("../templates", __FILE__)

      check_class_collision

      class_option(:parent,
                   type: :string,
                   desc: "The parent class for the generated model")

      class_option(:subtemplate,
                   type: :string,
                   desc: "Subtemplate")

      class_option(:view_name,
                   type: :string,
                   desc: "Filename for template file")

      def create_template
        template("template.rb",
                 File.join("app/templates",
                           class_path,
                           "#{file_name}_template.rb"))
      end

      def create_view
        copy_file("view.html.erb",
                  File.join("app/views/pages/templates",
                            class_path,
                            "#{file_name}.html.erb"))
      end

      protected

      def class_name
        super + "Template"
      end

      def default_subtemplate
        file_name + "_item"
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
