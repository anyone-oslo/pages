class PagesCore::Admin::PartialsController < Admin::AdminController
	
	before_filter :load_partial, :only => [ :show, :edit, :update, :destroy ]

	def index
		#@partials = Partial.names.map{ |name| [ name, Partial.find_by_name( name ) ] }
		@partials = Partial.find( :all, :order => :name ).mapped.translate( @language )
	end
	
	def show
	end
	
	def new
	end
	
	def edit
		
	end
	
	def create
		if PageFragment.create( params[:fragment] )
			flash[:notice] = "Element created."
			redirect_to admin_elements_path
		else
			flash.now[:error] = "There were problems saving your changes."
			render :action => :new
		end
	end
	
	def update
		if @fragment.update_attributes( params[:fragment] )
			flash[:notice] = "Your changes were saved."
			redirect_to admin_elements_path
		else
			flash.now[:error] = "There were problems saving your changes."
			render :action => :edit
		end
	end
	
	def destroy
		@fragment.destroy!
		flash[:notice] = "Element deleted."
		redirect_to admin_elements_path
	end
	
	protected
	
		def load_partial
			unless @partial = Partial.find( params[:id] ) rescue nil
				flash[:error] = "Cannot load element with ID #{params[:id]}"
			end
		end
	
end