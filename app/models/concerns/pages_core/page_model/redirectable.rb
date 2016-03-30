# encoding: utf-8

module PagesCore
  module PageModel
    module Redirectable
      extend ActiveSupport::Concern

      included do
        validates(:redirect_to,
                  format: { with: %r{\A(/|https?://).+\z},
                            allow_nil: true,
                            allow_blank: true })
      end

      # Returns boolean true if page has a valid redirect
      def redirects?
        redirect_to?
      end

      def redirect_path(params = {})
        path = redirect_to.dup
        if path.start_with? "/"
          params.each do |key, value|
            unless value.is_a?(String) || value.is_a?(Symbol)
              raise "redirect_url param must be a string or a symbol"
            end
            path.gsub!("/:#{key}", "/#{value}")
          end
        end
        path
      end
    end
  end
end
