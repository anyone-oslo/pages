# encoding: utf-8

module PagesCore
  module PageModel
    module Localizable
      extend ActiveSupport::Concern

      included do
        localizable do
          attribute :name
          attribute :body
          attribute :excerpt
          attribute :headline
          attribute :boxout

          attribute :path_segment
          attribute :meta_title
          attribute :meta_description
          attribute :open_graph_title
          attribute :open_graph_description

          dictionary(lambda do
            PagesCore::Templates::TemplateConfiguration.all_blocks
          end)
        end
      end
    end
  end
end
