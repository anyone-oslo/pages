# encoding: utf-8

module PagesCore
  module ExceptionHandler
    module Rescues40x
      extend ActiveSupport::Concern
      included do
        rescue_from PagesCore::NotAuthorized,            with: :handle_exception
        rescue_from ActiveRecord::RecordNotFound,        with: :handle_exception
        rescue_from ActionController::RoutingError,      with: :handle_exception
      end
    end

    module Rescues
      extend ActiveSupport::Concern
      included do
        rescue_from Exception,                           with: :handle_exception
        rescue_from ActionController::UnknownController, with: :handle_exception
        rescue_from AbstractController::ActionNotFound,  with: :handle_exception
      end
    end

    extend ActiveSupport::Concern

    included do
      return if Rails.application.config.consider_all_requests_local
      include PagesCore::ExceptionHandler::Rescues40x
      if PagesCore.config.exception_handler?
        include PagesCore::ExceptionHandler::Rescues
      end
    end

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

    def log_error(exception)
      trace = exception.backtrace
      ActiveSupport::Deprecation.silence do
        message = "\n#{exception.class} (#{exception.message}):\n"
        if exception.respond_to?(:annoted_source_code)
          message << exception.annoted_source_code.to_s
        end
        message << "  " << trace.join("\n  ")
        logger.fatal("#{message}\n\n")
      end
    end

    def env_as_object
      request.env.each_with_object({}) do |hash, value|
        if value.first.is_a?(String) && value.last.is_a?(String)
          hash[value.first] = value.last
        end
      end
    end

    def filtered_backtrace(exception)
      Rails.backtrace_cleaner.send(:filter, exception.backtrace)
    end

    def exception_url
      [
        "http://", request.env["HTTP_HOST"], request.env["REQUEST_URI"]
      ].compact.join
    end

    def error_report(exception)
      {
        message: exception.to_s,
        url: exception_url,
        params: params,
        env: env_as_object,
        session: session.to_hash,
        backtrace: filtered_backtrace(exception),
        timestamp: Time.now.utc,
        user_id: logged_in? ? current_user.id : nil
      }
    end

    def write_error(str)
      sha1_hash = Digest::SHA1.hexdigest(str)
      error_report_dir  = Rails.root.join("log", "error_reports")
      error_report_file = error_report_dir.join("#{sha1_hash}.yml")
      `mkdir -p #{error_report_dir}` unless File.exist?(error_report_dir)

      unless File.exist?(error_report_file)
        File.open(error_report_file, "w") do |fh|
          fh.write str
        end
      end
      sha1_hash
    end

    def handle_critical_exception(exception)
      logger.fatal "Error in handle_exception"
      log_error(exception)
      render(template: "errors/500_critical", status: 500, layout: false)
    end

    def handle_exception(exception)
      log_error(exception)
      return if handle_40x(exception)
      @error_id = write_error(error_report(exception).to_yaml)
      session[:error_report] = @error_id
      logger.error "Logged error #{@error_id}"
      render_error 500
    rescue => error
      handle_critical_exception(error)
    end

    private

    def handle_40x(exception)
      if exception.is_a?(ActionController::RoutingError) ||
         exception.is_a?(ActiveRecord::RecordNotFound)
        render_error 404
      elsif exception.is_a?(PagesCore::NotAuthorized)
        render_error 403
      else
        false
      end
    end
  end
end
