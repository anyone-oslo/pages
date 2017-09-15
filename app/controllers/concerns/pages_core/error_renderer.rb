# encoding: utf-8

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
      options[:template] ||= "errors/#{error}"
      options[:layout] = error_layout(error) unless options.key?(:layout)
      @email = logged_in? ? current_user.email : ""
      render options
      true
    end

    protected

    def error_layout(error)
      if error == 404 && PagesCore.config.error_404_layout?
        PagesCore.config.error_404_layout
      else
        "errors"
      end
    end
  end
end
