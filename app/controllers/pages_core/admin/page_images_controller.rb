class PagesCore::Admin::PageImagesController < Admin::AdminController

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
				@page_image = @page.page_images.find(params[:id])
			rescue ActiveRecord::RecordNotFound
				flash[:notice] = "Could not find PageImage with ID ##{params[:id]}"
				redirect_to admin_page_path(@language, @page) and return
			end
		end

	public

		def index
			@page_images = @page.page_images
			respond_to do |format|
				format.json do
					render :json => '[' + @page_images.map{|pi| pi.to_json}.join(', ') + ']'
				end
			end
		end

		def reorder
			@page_images = params[:ids].map{|id| PageImage.find(id)}
			@page_images.each_with_index do |pi, i|
				pi.update_attribute(:position, i)
			end
			respond_to do |format|
				format.json do
					render :json => '[' + @page_images.map{|pi| pi.to_json}.join(', ') + ']'
				end
			end
		end

		def show
		end

		def new
			@page_image = @page.page_images.new
		end

		def create
			if params[:page_image]
				@page.page_images.create(params[:page_image])
			elsif params[:page_images]
				params[:page_images].each do |index, attributes|
					@page.page_images.create(attributes) if attributes[:image] && attributes[:image] != ""
				end
			end
			redirect_to admin_page_path(:language => @language, :id => @page, :anchor => 'images') and return
		end

		def update
			if @page_image.update_attributes(params[:page_image])

				# Empty the cache
				cache_path = File.join(RAILS_ROOT, "public/cache/dynamic_image/#{@page_image.image.id}")
				if File.exists?(cache_path)
					`rm -rf #{cache_path}`
				end

				respond_to do |format|
					format.html do
						flash[:notice] = "The image was updated"
						redirect_to admin_page_path(:language => @language, :id => @page, :anchor => 'images') and return
					end
					format.json do
						render :json => @page_image.to_json
					end
				end
			else
				render :action => :edit
			end
		end

		def destroy
			@page_image.destroy
			respond_to do |format|
				format.html do
					flash[:notice] = "The image was deleted"
					redirect_to admin_page_path(:language => @language, :id => @page, :anchor => 'images') and return
				end
				format.json do
					render :json => @page_image.to_json
				end
			end
		end

end