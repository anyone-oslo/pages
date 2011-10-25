class PagesCore::Frontend::PageFilesController < FrontendController

	before_filter :find_page_file, :only => [:show, :edit, :update, :destroy]

	protected

		def find_page_file
			begin
				@page_file = PageFile.find(params[:id])
			rescue ActiveRecord::RecordNotFound
				flash[:notice] = "Could not find PageFile with ID ##{params[:id]}"
				redirect_to page_files_url and return
			end
		end
	
	public

		def show
			minTime = Time.rfc2822(request.env["HTTP_IF_MODIFIED_SINCE"]) rescue nil
			if minTime && @page_file.created_at? && @page_file.created_at <= minTime
				render :text => '304 Not Modified', :status => 304 and return
			end
			response.headers['Last-Modified']       = @page_file.created_at.httpdate if @page_file.created_at?
			send_data(
				@page_file.data, 
				:filename    => @page_file.filename, 
				:type        => @page_file.content_type, 
				:disposition => 'attachment'
			)
		end
	
end