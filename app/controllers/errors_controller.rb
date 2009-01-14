class ErrorsController < ApplicationController
	
	layout 'errors'
	
	skip_before_filter :verify_authenticity_token

	def report
		@error_report = session[:error_report]
		@from         = params[:email]
		@description  = params[:description]
		@site_name    = Pages.config :site_name
		AdminMailer.deliver_error_report( :error_report => @error_report, :from => @from, :description => @description, :site_name => @site_name )
	end
	
	
end