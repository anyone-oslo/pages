class PagesCore::Admin::PagesController < Admin::AdminController

	before_filter :find_page, :only => [
		:show, :edit, :preview, :update, :destroy, :reorder,
		:add_image, :delete_image,
		:delete_language, :delete_comment, :delete_presentation_image,
		:import_xml
	]
	before_filter :application_languages
	before_filter :load_categories
	before_filter :load_news_pages, :only => [:news, :new_news]

	protected

		def find_page
			begin
				@page = Page.find(params[:id]).translate(@language)
			rescue
				flash[:notice] = "Cannot load page with id ##{params[:id]}"
				redirect_to admin_pages_path and return
			end
		end

		def application_languages
			@application_languages = Textbit.languages
		end

		def load_categories
			@categories = Category.find(:all, :order => [:name])
		end

		def load_news_pages
			@news_pages = Page.news_pages(:language => @language)
			unless @news_pages && @news_pages.length > 0
				flash[:notice] = "No pages have been flagged as news pages"
				redirect_to admin_pages_url(:language => @language) and return
			end
		end

	public

		def index
			@root_pages = Page.root_pages(
				:drafts        => true,
				:hidden        => true,
				:all_languages => true,
				:autopublish   => true,
				:language      => @language
			)
			respond_to do |format|
				format.html
				format.xml do
					render :xml => @root_pages.to_xml(:pages => true)
				end
			end
		end

		def news
			count_options = {
				:drafts        => true,
				:hidden        => true,
				:all_languages => true,
				:autopublish   => true,
				:language      => @language,
				:parent        => @news_pages
			}

			# Are we queried by category?
			if params[:category]
				@category = Category.find_by_slug(params[:category])
				unless @category
					flash[:notice] = "Cannot find that category"
					redirect_to news_admin_pages_url(:language => @language) and return
				end
				count_options[:category] = @category
			end
			@archive_count = Page.count_pages_by_year_and_month(count_options)

			# Set @year and @month from params, default to the last available one
			last_year  = !@archive_count.empty? ? @archive_count.keys.last.to_i : Time.now.year
			last_month = (@archive_count && @archive_count[last_year]) ? @archive_count[last_year].keys.last.to_i : Time.now.month

			@year  = (params[:year]  || last_year).to_i
			@month = (params[:month] || last_month).to_i

			# Let's check that there's data for the queried @year and @month
			unless @archive_count.empty?
				unless @archive_count[@year] && @archive_count[@year][@month] && @archive_count[@year][@month] > 0
					flash[:notice] = "No news posted in the given range"
					redirect_to news_admin_pages_url(:language => @language) and return
				end
			end

			# Make the range
			@published_range = (starts_at = DateTime.new(@year, @month, 1))...(starts_at.end_of_month)

			# And grab the pages
			@news_items = Page.get_pages(count_options.merge({:published_within => @published_range, :order => 'published_at DESC'}))
		end

		def list
			redirect_to admin_pages_url(:language => @language)
		end

		def search
			raise "Not implemented"
		end

		def reorder_pages
			pages = params[:ids].map{|id| Page.find(id)}
			PagesCore::CacheSweeper.disable do
				pages.each_with_index do |page, index|
					page.update_attribute(:position, (index + 1))
				end
			end
			PagesCore::CacheSweeper.sweep!
			if request.xhr?
				render :text => 'ok'
			end
		end

		def show
			edit
			render :action => :edit
		end

		def import_xml
			if request.post? && params[:xmlfile]
				@created_pages = @page.import_xml(params[:xmlfile].read)
			end
		end

		def new
			@page = Page.new.translate(@language)
			if params[:parent]
				@page.parent = Page.find(params[:parent]) rescue nil
			elsif @news_pages
				@page.parent = @news_pages.first
			end
		end

		def new_news
			new
			render :action => :new
		end

		def create
			@page = Page.new.translate(@language)
			params[:page].delete(:image) if params[:page].has_key?(:image) && params[:page][:image].blank?
			@page.author = @current_user

			if @page.update_attributes(params[:page])
				@page.update_attribute(:comments_allowed, @page.template_config.value(:comments_allowed))
				@page.categories = (params[:category] && params[:category].length > 0) ? params[:category].map{|k,v| Category.find(k.to_i)} : []
				if params[:page_image_description]
					begin
						@page.image.update_attribute(:description, params[:page_image_description])
					rescue
						# Alert?
					end
				end
				redirect_to edit_admin_page_url(@language, @page)
			else
				render :action => :new
			end
		end

		def edit
			@authors = User.find(:all, :order => 'realname', :conditions => {:is_activated => true})
			@authors = [@page.author] + @authors unless @authors.include?(@page.author)
			@new_image ||= Image.new
		end

		def preview
			@page.attributes = params[:page]
			render :layout => false if request.xhr?
		end

		def update
			params[:page].delete(:image) if params[:page].has_key?(:image) && params[:page][:image].blank?
			if @page.update_attributes(params[:page])
				@page.categories = (params[:category] && params[:category].length > 0) ? params[:category].map{|k,v| Category.find(k.to_i)} : []
				if params[:page_image_description]
					begin
						@page.image.update_attribute(:description, params[:page_image_description])
					rescue
						# Alert?
					end
				end
				@page.save
				flash[:notice] = "Your changes were saved"
				flash[:save_performed] = true
				redirect_to edit_admin_page_url( @language, @page )
			else
				edit
				render :action => :edit
			end
		end

		def destroy
			@page = Page.find(params[:id])
			@page.set_status(:deleted)
			@page.save
			redirect_to :action => :list
		end

		def set_status
			@page = Page.find(params[:id])
			@page.set_status(params[:status])
			@page.save
			redirect_to :action => :list
		end

		def delete_comment
			@comment = @page.comments.select{|c| c.id == params[:comment_id].to_i}.first
			if @comment
				@comment.destroy
				flash[:notice] = "Comment deleted"
			end
			redirect_to edit_admin_page_url(:language => @language, :id => @page, :anchor => 'comments')
		end

		# Remove a language from a page
		def delete_language
			@page.destroy_language(@language)
			redirect_to admin_pages_url(:language => @language)
		end

		def reorder
			if params[:direction] == "up"
				@page.move_higher
			elsif params[:direction] == "down"
				@page.move_lower
			end
			redirect_to admin_pages_url(:language => @language)
		end

end
