class Admin::PageImagesController < Admin::AdminController

	before_filter :load_page
	before_filter :load_page_image, :only => [:show, :edit, :update, :destroy]

	protected

		def load_page
			begin
				@page = Page.find(params[:page_id])
			rescue ActiveRecord::RecordNotFound
				flash[:notice] = "Could not find PageImage with ID ##{params[:id]}"
				redirect_to admin_pages_path(@language) and return
			end
		end

		def load_page_image
			begin
			@page_file = @page.page_images.find(params[:id])
			rescue ActiveRecord::RecordNotFound
				flash[:notice] = "Could not find PageImage with ID ##{params[:id]}"
				redirect_to admin_page_path(@language, @page) and return
			end
		end
		
	public

		def index
			@page_images = @page.page_images
		end
		
		def show
		end
		
		def new
			@page_image = @page.page_images.new
		end
		
		def create
			@page_image = @page.page_images.create(params[:page_image])
			if @page_image.valid?
				flash[:notice] = "The image was created"
				redirect_to admin_page_path(@language, @page) and return
			else
				render :action => :new
			end
		end
		
		def update
			if @page_image.update_attributes(params[:page_image])
				flash[:notice] = "The image was updated"
				redirect_to admin_page_path(@language, @page) and return
			else
				render :action => :edit
			end
		end
		
		def destroy
			@page_image.destroy
			flash[:notice] = "The image was deleted"
			redirect_to admin_page_path(@language, @page) and return
		end

end