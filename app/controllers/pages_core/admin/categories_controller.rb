class PagesCore::Admin::CategoriesController < Admin::AdminController

	before_filter :find_category, :only => [:show, :edit, :update, :destroy]

	protected

		def find_category
			begin
				@category = Category.find(params[:id])
			rescue ActiveRecord::RecordNotFound
				flash[:notice] = "Could not find Category with ID ##{params[:id]}"
				redirect_to admin_pages_url(:language => @language) and return
			end
		end
	
	public

		def index
			@categories = Category.find(:all)
		end
	
		def show
			render :action => :edit
		end
	
		def new
			@category = Category.new
		end
	
		def create
			@category = Category.create(params[:category])
			if @category.valid?
				flash[:notice] = "New category created"
				redirect_to admin_pages_url(:language => @language) and return
			else
				render :action => :new
			end
		end
	
		def edit
		end
	
		def update
			if @category.update_attributes(params[:category])
				flash[:notice] = "Category was updated"
				redirect_to admin_pages_url(:language => @language) and return
			else
				render :action => :edit
			end
		end

		def destroy
			@category.destroy
			flash[:notice] = "Category was deleted"
			redirect_to admin_pages_url(:language => @language) and return
		end

end