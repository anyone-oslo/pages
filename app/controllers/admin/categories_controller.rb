class Admin::CategoriesController < Admin::AdminController

	def load_category
		@category = Category.find( params[:id] ) rescue nil
		unless @category
			flash[:notice] = "Could not find Category with ID ##{params[:id]}"
			redirect_to admin_pages_url(:language => @language) and return
		end
	end
	protected     :load_category
	before_filter :load_category, :only => [ :show, :edit, :update, :destroy ]
	

	def index
		@categories = Category.find( :all )
	end
	
	def show
		render :action => :edit
	end
	
	def new
		@category = Category.new
	end
	
	def create
		@category = Category.create( params[:category] )
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
		if @category.update_attributes( params[:category] )
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