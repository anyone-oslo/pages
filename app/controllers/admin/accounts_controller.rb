class Admin::AccountsController < Admin::AdminController
	
	def index
		redirect_to edit_admin_account_path( @account )
	end
	
	def edit
		@database_size = @account.database_size
		@domain        = @account.domain || request.domain.gsub( /^www\./, '' )
		@stats         = PagesCore::AWStats.new( @domain )
		@plans         = YAML.load( URI.parse( "http://pages.manualdesign.no/plans/" ).read ) rescue []
		@plan          = @plans.select{ |p| p[:key] == @account.plan }.first
	end
	
	def update
		if @account.update_attributes( params[:account] )
			flash[:notice] = "Your account details were saved"
			redirect_to edit_admin_account_path( @account )
		else
			flash.now[:error] = "There were problems saving your account details"
			render :action => :edit
		end
	end
	
end