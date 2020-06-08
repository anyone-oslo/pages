# frozen_string_literal: true

module PagesCore
  module ErrorRenderer
    extend ActiveSupport::Concern
    # Renders a fancy error page from app/views/errors. If the error name
    # is numeric, it will also be set as the response status. Example:
    #
    #   render_error 404
    #
    def render_error(error, options = {})
      options[:status] ||= error if error.is_a? Numeric
      respond_to do |format|
        format.html do
          options[:layout] = error_layout(error, options)
          @email = current_user.try(&:email) || ""
          render({ template: "errors/#{error}" }.merge(options))
        end
        format.any { head options[:status] }
      end
      true
    end

    protected

    def error_layout(error, options = {})
      return options[:layout] if options.key?(:layout)

      if error == 404 && PagesCore.config.error_404_layout?
        PagesCore.config.error_404_layout
      else
        "errors"
      end
    end
  end
end
