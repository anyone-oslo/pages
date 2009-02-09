require 'iconv'

class Admin::PagesController < Admin::AdminController

	def find_page
		begin
			@page = Page.find( params[:id] ).translate( @language )
		rescue
			flash[:notice] = "Cannot load user with id ##{params[:id]}"
			redirect_to admin_pages_path and return
		end
	end
	private       :find_page
	before_filter :find_page, :only => [ :show, :edit, :preview, :update, :destroy, :reorder, :add_image, :delete_image, :delete_language, :delete_comment, :delete_presentation_image ]
	
	def application_languages
		@application_languages = Textbit.languages
	end
	before_filter :application_languages
	
	def load_categories
		@categories = Category.find(:all, :order => [:name])
	end
	before_filter :load_categories
	protected     :load_categories
	


	# --- COLLECTION ---------------------------------------------------------

	def index
		@root_pages = Page.root_pages( 
			:drafts        => true, 
			:hidden        => true, 
			:all_languages => true, 
			:language      => @language 
		)
		@all_pages = Page.get_pages(:language => @language, :drafts => true, :hidden => true, :all_languages => true, :skip_parent => true)
	end
	
	def news
		@section_id = persistent_param(:section, "all")
		@news_pages = Page.news_pages(:language => @language)
		@news_items = Page.get_news(
			:language => @language, 
			:drafts => true, 
			:hidden => true, 
			:all_languages => true,
			:parent => (@section_id.to_s =~ /^[\d]+$/) ? @section_id : @news_pages
		)
	end

	def list
		redirect_to admin_pages_url( :language => @language )
	end



	# --- MEMBER -------------------------------------------------------------

	def show
		edit
		render :action => :edit
	end
	
	def new
		@page = Page.new.translate( @language )
		if params[:parent]
			@page.parent = Page.find( params[:parent] ) rescue nil
		end
	end

	def create
		@page = Page.new.translate( @language )
		@page.author = @current_user
		textbit_attributes = {}
		[:name, :body, :excerpt, :headline].each do |attrib|
			if params[:page].has_key?(attrib)
				textbit_attributes[attrib] = params[:page][attrib] 
				params[:page].delete(attrib)
			end
		end
		if @page.update_attributes(params[:page])
			textbit_attributes.each do |attrib,value|
				@page.update_attribute(attrib, value)
			end
			redirect_to edit_admin_page_url( @language, @page )
		else
			render :action => :new
		end
	end

	def edit
		@authors = User.find( :all )
		@new_image ||= Image.new
		if params[:show_tab]
			@show_tab = params[:show_tab]
		end
	end

	def preview
		#@page = Page.new( params[:page] )
		@page.attributes = params[:page]
		render :layout => false if request.xhr?
	end

	def update
		if params[:page].has_key? :image
			params[:page].delete( :image ) if params[:page][:image].blank?
		end	
		textbit_attributes = {}
		[:name, :body, :excerpt, :headline].each do |attrib|
			if params[:page].has_key?(attrib)
				textbit_attributes[attrib] = params[:page][attrib] 
				params[:page].delete(attrib)
			end
		end
		if @page.update_attributes( params[:page] )
			textbit_attributes.each do |attrib,value|
				@page.update_attribute(attrib, value)
			end
		    if params[:category] && params[:category].length > 0
			    @page.categories = params[:category].map{|k,v| Category.find(k.to_i)}
		    else
		        @page.categories = []
		    end
		    if params[:page_image_description]
		        begin
		            @page.image.update_attribute(:description, params[:page_image_description])
		        rescue
		            # Alert?
	            end
	        end
			flash[:notice] = "Your changes were saved"
			flash[:save_performed] = true
			redirect_to edit_admin_page_url( @language, @page )
		else
			edit
			render :action => :edit
		end

	end


	def add_image
		@page.images.create( params[:image] )
		redirect_to edit_admin_page_url( :language => @language, :id => @page, :show_tab => 'additional images' )
	end
	
	def delete_image
		@image = @page.images.select{ |i| i.id == params[:image_id].to_i }.first rescue nil
		if @image
			@page.images.delete( @image )
			@image.destroy
		end
		redirect_to edit_admin_page_url( :language => @language, :id => @page, :show_tab => 'additional images' )
	end
	
	def delete_presentation_image
		if @page.image
			@page.image.destroy
			flash[:notice] = "Image deleted"
		end
		redirect_to edit_admin_page_url( :language => @language, :id => @page, :show_tab => 'presentation' )
	end
	
	def update_image_caption
		@image = Image.find(params[:image_id]) rescue nil
		if @image
			@image.update_attribute(:byline, params[:caption])
			render :text => @image.byline
		else
			render :text => "ERROR! Could not update caption."
		end
	end

	def destroy
		@page = Page.find( params[:id] )
		@page.set_status :deleted
		@page.save
		redirect_to :action => :list
	end

	def set_status
		@page = Page.find( params[:id] )
		@page.set_status params[:status]
		@page.save
		redirect_to :action => :list
	end

	def delete_comment
		@comment = @page.comments.select{ |c| c.id == params[:comment_id].to_i }.first
		if @comment
			@comment.destroy
			flash[:notice] = "Comment deleted"
		end
		redirect_to edit_admin_page_url( :language => @language, :id => @page, :show_tab => 'comments' )
	end
	

	# Remove a language from a page
	def delete_language
		@page.destroy_language( @language )
		#redirect_to :action => :edit, :id => @page
		redirect_to admin_pages_url( :language => @language )
	end


	def add_language
		@page = Page.find( params[:id] )
		if params[:language]
			@page.add_language( params[:language] )
			redirect_to :action => :edit, :id => @page, :language => params[:language]
		end
		@all_languages = Language.codes_and_names.collect {|lang| [lang[:name], lang[:code]] }
		@application_languages = Textbit.languages.collect { |code| [ Language.name_for_code( code ), code ] }
	end

	def reorder
		if params[:direction] == "up"
			@page.move_higher
		elsif params[:direction] == "down"
			@page.move_lower
		end

		redirect_to :action => :index
	end
	
end
