# frozen_string_literal: true

module PagesCore
  module Admin
    module ContentTabsHelper
      def content_tab(name, options = {}, &block)
        @content_tabs ||= []
        return unless block_given?

        tab = {
          name: name.to_s.humanize,
          key: options[:key] || name.to_s.underscore.gsub(/\s+/, "_"),
          options: options,
          content: capture(&block)
        }
        @content_tabs << tab
        content_tab_tag(tab[:key], tab[:content])
      end

      private

      def content_tab_tag(key, content)
        tag.div(content,
                class: "content-tab",
                id: "content-tab-#{key}",
                role: "tabpanel",
                data: { tab: key,
                        "main-target" => "tab" })
      end
    end
  end
end
