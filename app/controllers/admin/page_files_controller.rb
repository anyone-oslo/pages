class Admin::PageFilesController < Admin::AdminController

	def load_page
		@page = Page.find( params[:page_id] ) rescue nil
		unless @page
			flash[:notice] = "Could not find PageFile with ID ##{params[:id]}"
			redirect_to admin_pages_path( @language ) and return
		end
	end
	protected     :load_page
	before_filter :load_page

	def load_page_file
		@page_file = @page.files.find( params[:id] ) rescue nil
		unless @page_file
			flash[:notice] = "Could not find PageFile with ID ##{params[:id]}"
			redirect_to admin_page_path( @language, @page ) and return
		end
	end
	protected     :load_page_file
	before_filter :load_page_file, :only => [ :show, :edit, :update, :destroy ]
	

	def index
		#@page_files = PageFile.find( :all )
		redirect_to admin_page_path( @language, @page ) and return
	end
	
	def reorder
		params[:filelist].each_with_index { |id,idx| PageFile.update(id, :position => idx) }
		if request.xhr?
			render :text => 'ok' and return
		end
		redirect_to admin_page_path( @language, @page ) and return
	end
	
	def show
		redirect_to admin_page_path( @language, @page ) and return
	end
	
	def new
		#@page_file = PageFile.new
		redirect_to admin_page_path( @language, @page ) and return
	end
	
	def create
		@page_file = @page.files.new
		@page_file.update_attributes(params[:page_file])
		if @page_file.valid?
			flash[:notice] = "File uploaded"
		else
			flash[:notice] = "Error uploading file!"
		end
		redirect_to admin_page_path( @language, @page ) and return
	end
	
	def edit
		redirect_to admin_page_path( @language, @page ) and return
	end
	
	def update
		if @page_file.update_attributes( params[:page_file] )
			flash[:notice] = "File updated"
		else
			flash[:notice] = "Error updating file!"
		end
		redirect_to admin_page_path( @language, @page ) and return
	end
	
	def destroy
		@page_file.destroy
		flash[:notice] = "File deleted"
		redirect_to admin_page_path( @language, @page ) and return
	end
	
end