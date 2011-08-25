class Admin::PageFilesController < Admin::AdminController

	before_filter :load_page
	before_filter :load_page_file, :only => [:show, :edit, :update, :destroy]

	protected

		def load_page
			begin
				@page = Page.find(params[:page_id])
			rescue ActiveRecord::RecordNotFound
				flash[:notice] = "Could not find PageFile with ID ##{params[:id]}"
				redirect_to admin_pages_path( @language ) and return
			end
		end

		def load_page_file
			begin
				@page_file = @page.files.find(params[:id])
			rescue ActiveRecord::RecordNotFound
				flash[:notice] = "Could not find PageFile with ID ##{params[:id]}"
				redirect_to admin_page_path(@language, @page) and return
			end
		end
	
	public

		def index
			redirect_to admin_page_path(@language, @page) and return
		end
	
		def reorder
			params[:filelist].each_with_index{|id,idx| PageFile.update(id, :position => idx)}
			if request.xhr?
				render :text => 'ok' and return
			end
			redirect_to admin_page_path(@language, @page) and return
		end
	
		def show
			redirect_to admin_page_path(@language, @page) and return
		end
	
		def new
			redirect_to admin_page_path(@language, @page) and return
		end
	
		def create
			@page_file = @page.files.new
			@page_file.update_attributes(params[:page_file])
			if @page_file.valid?
				flash[:notice] = "File uploaded"
			else
				flash[:notice] = "Error uploading file!"
			end
			redirect_to admin_page_path(@language, @page) and return
		end
	
		def edit
			redirect_to admin_page_path(@language, @page) and return
		end
	
		def update
			if @page_file.update_attributes(params[:page_file])
				flash[:notice] = "File updated"
			else
				flash[:notice] = "Error updating file!"
			end
			redirect_to admin_page_path(@language, @page) and return
		end
	
		def destroy
			@page_file.destroy
			flash[:notice] = "File deleted"
			redirect_to admin_page_path(@language, @page) and return
		end
	
end