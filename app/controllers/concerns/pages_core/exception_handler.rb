# encoding: utf-8

module PagesCore
  module PagesCore::ExceptionHandler
    extend ActiveSupport::Concern

    included do
      unless Rails.application.config.consider_all_requests_local
        rescue_from Exception,                           with: :handle_exception
        rescue_from ActiveRecord::RecordNotFound,        with: :handle_exception
        rescue_from ActionController::RoutingError,      with: :handle_exception
        rescue_from ActionController::UnknownController, with: :handle_exception
        rescue_from AbstractController::ActionNotFound,  with: :handle_exception
      end
    end

    # Renders a fancy error page from app/views/errors. If the error name is numeric,
    # it will also be set as the response status. Example:
    #
    #   render_error 404
    #
    def render_error(error, options={})
      options[:status] ||= error if error.kind_of? Numeric
      options[:template] ||= "errors/#{error}"
      options[:layout] ||= 'errors'
      @email = (@current_user) ? @current_user.email : ""
      render options
    end

    protected

    def log_error(exception)
      trace = exception.backtrace
      ActiveSupport::Deprecation.silence do
        message = "\n#{exception.class} (#{exception.message}):\n"
        message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
        message << "  " << trace.join("\n  ")
        logger.fatal("#{message}\n\n")
      end
    end

    def handle_exception(exception)
      begin
        log_error exception
        if exception.kind_of?(ActionController::RoutingError)
          render_error 404
        else
          # Generate the error report
          error_report = {}
          error_report[:message]   = exception.to_s
          error_report[:url]       = "http://"+request.env['HTTP_HOST']
          error_report[:url]      += request.env['REQUEST_URI'] if request.env['REQUEST_URI']
          error_report[:params]    = params
          error_report[:env]       = request.env.inject({}) do |hash, value|
            if value.first.kind_of?(String) && value.last.kind_of?(String)
              hash[value.first] = value.last
            end
            hash
          end
          error_report[:session]   = session.to_hash
          error_report[:backtrace] = Rails.backtrace_cleaner.send(:filter, exception.backtrace)
          error_report[:timestamp] = Time.now
          if @current_user
            error_report[:user_id] = @current_user.id
          end

          sha1_hash = Digest::SHA1.hexdigest(error_report.to_yaml)

          error_report_dir  = Rails.root.join('log', 'error_reports')
          error_report_file = error_report_dir.join("#{sha1_hash}.yml")
          `mkdir -p #{error_report_dir}` unless File.exists?(error_report_dir)

          unless File.exists?(error_report_file)
            File.open(error_report_file, 'w') do |fh|
              fh.write error_report.to_yaml
            end
          end

          session[:error_report] = sha1_hash
          @error_id = sha1_hash
          render_error 500
        end
      rescue
        render(:template => 'errors/500_critical', :status => 500, :layout => false) and return
      end
    end

  end
end