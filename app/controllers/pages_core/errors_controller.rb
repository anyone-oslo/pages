# encoding: utf-8

class PagesCore::ErrorsController < ApplicationController

	layout 'errors'

	skip_before_filter :verify_authenticity_token

	def report
		if session[:error_report]
			error_report_dir  = File.join(RAILS_ROOT, 'log/error_reports')
			error_report_file = File.join(error_report_dir, "#{session[:error_report]}.yml")
			@error_report = YAML.load_file(error_report_file)
			@from         = params[:email]
			@description  = params[:description]
			@site_name    = PagesCore.config :site_name
			if @error_report[:user_id]
				@error_report[:user] = User.find(@error_report[:user_id]) rescue nil
			end
			AdminMailer.deliver_error_report(:error_report => @error_report, :from => @from, :description => @description, :site_name => @site_name)
			@error_id = session[:error_report]
		end
	end


end