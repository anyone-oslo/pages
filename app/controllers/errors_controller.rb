# encoding: utf-8

class ErrorsController < ::ApplicationController
  layout "errors"

  skip_before_action :verify_authenticity_token

  def report
    return unless session[:error_report]
    deliver_error_report(
      find_error_report,
      params[:email],
      params[:description]
    )
    @error_id = session[:error_report]
  end

  def show
    render_error params[:id].to_i
  end

  def not_found
    render_error 404
  end

  def unacceptable
    render_error 422
  end

  def internal_error
    render_error 500
  end

  private

  def deliver_error_report(report, from, description)
    AdminMailer.error_report(report, from, description).deliver_now
  end

  def find_error_report
    report = YAML.load_file(error_report_path)
    if report[:user_id]
      report[:user] = begin
                        User.find(report[:user_id])
                      rescue
                        nil
                      end
    end
    report
  end

  def error_report_path
    Rails.root
         .join("log", "error_reports")
         .join("#{session[:error_report]}.yml")
  end
end
