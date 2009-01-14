class PageFilesController < ApplicationController

	#caches_page :show

	def load_page_file
		@page_file = PageFile.find( params[:id] ) rescue nil
		unless @page_file
			flash[:notice] = "Could not find PageFile with ID ##{params[:id]}"
			redirect_to page_files_url and return
		end
	end
	protected     :load_page_file
	before_filter :load_page_file, :only => [ :show, :edit, :update, :destroy ]
	

	def index
		raise "Not implemented"
		@page_files = PageFile.find( :all )
	end
	
	def show
		minTime = Time.rfc2822( request.env[ "HTTP_IF_MODIFIED_SINCE" ] ) rescue nil
		if minTime && @page_file.created_at? && @page_file.created_at <= minTime
			render :text => '304 Not Modified', :status => 304 and return
		end
		response.headers['Cache-Control'] = nil
		response.headers['Content-Disposition'] = "attachment"
		response.headers['Last-Modified'] = @page_file.created_at.httpdate if @page_file.created_at?
		send_data( @page_file.data, :filename => @page_file.filename, :type => @page_file.content_type, :disposition => 'attachment' )
	end
	
	def new
		raise "Not implemented"
		@page_file = PageFile.new
	end
	
	def create
		raise "Not implemented"
		@page_file = PageFile.create( params[:page_file] )
		if @page_file.valid?
			flash[:notice] = "New PageFile created"
			redirect_to page_files_url and return
		else
			render :action => :new
		end
	end
	
	def edit
		raise "Not implemented"
	end
	
	def update
		raise "Not implemented"
		if @page_file.update_attributes( params[:page_file] )
			flash[:notice] = "PageFile was updated"
			redirect_to page_files_url and return
		else
			render :action => :edit
		end
	end

	def destroy
		raise "Not implemented"
		@page_file.destroy
		flash[:notice] = "PageFile was deleted"
		redirect_to page_files_url and return
	end

end