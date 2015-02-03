# encoding: utf-8

class ErrorsController < ApplicationController

  layout 'errors'

  skip_before_action :verify_authenticity_token

  def report
    if session[:error_report]
      error_report_dir  = Rails.root.join('log', 'error_reports')
      error_report_file = error_report_dir.join("#{session[:error_report]}.yml")
      @error_report = YAML.load_file(error_report_file)
      @from         = params[:email]
      @description  = params[:description]
      if @error_report[:user_id]
        @error_report[:user] = User.find(@error_report[:user_id]) rescue nil
      end
      AdminMailer.error_report(@error_report, @from, @description).deliver_now
      @error_id = session[:error_report]
    end
  end

  def show
    render_error params[:id].to_i
  end

end
