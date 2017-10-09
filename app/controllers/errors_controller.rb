# encoding: utf-8

class ErrorsController < ::ApplicationController
  layout "errors"

  def report
    report = decrypt_report(params[:error_report])
    report[:user] = User.find_by(id: report[:user_id]) if report.key?(:user_id)

    deliver_error_report(report, params[:email], params[:description])
  end

  def show
    render_error params[:id].to_i
  end

  def forbidden
    render_error 403
  end

  def not_found
    render_error 404
  end

  def unacceptable
    render_error 422
  end

  def unauthorized
    render_error 401
  end

  def internal_error
    exception = request.env["action_dispatch.exception"]
    if !exception
      render_error 500
    elsif exception.is_a?(PagesCore::NotAuthorized)
      render_error 403
    else
      @report = encrypt_report(error_report(request, exception))
      wrapper = ActionDispatch::ExceptionWrapper.new(nil, exception)
      render_error wrapper.status_code
    end
  end

  private

  def deliver_error_report(report, from, description)
    AdminMailer.error_report(report, from, description).deliver_now
  end

  def decrypt_report(str)
    YAML.load(report_encryptor.decrypt_and_verify(str))
  end

  def encrypt_report(report)
    report_encryptor.encrypt_and_sign(report.to_yaml)
  end

  def error_report(request, exception)
    { message:   exception.to_s,
      url:       request.original_url,
      env:       request.env.select { |_, v| v.is_a?(String) },
      params:    params.to_unsafe_h,
      session:   session.to_hash,
      backtrace: exception_backtrace(exception),
      timestamp: Time.now.utc,
      user_id:   current_user.try(&:id) }
  end

  def exception_backtrace(exception)
    Rails.backtrace_cleaner.send(:filter, exception.backtrace)
  end

  def report_encryptor
    ActiveSupport::MessageEncryptor.new(
      ActiveSupport::CachingKeyGenerator.new(
        ActiveSupport::KeyGenerator.new(
          Rails.application.secrets.secret_key_base,
          iterations: 1000
        )
      ).generate_key("encrypted error report")
    )
  end
end
