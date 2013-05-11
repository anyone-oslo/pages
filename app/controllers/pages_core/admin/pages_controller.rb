# encoding: utf-8

class PagesCore::Admin::PagesController < Admin::AdminController

  before_filter :find_page, only: [
    :show, :edit, :preview, :update, :destroy, :reorder,
    :delete_comment,
    :import_xml
  ]
  before_filter :find_categories
  before_filter :find_news_pages, only: [:news, :new_news]

  def index
    @root_pages = Page.roots.in_locale(@language).visible
    respond_to do |format|
      format.html
      format.xml do
        render xml: @root_pages.to_xml(pages: true)
      end
    end
  end

  def news
    # Redirect away if no news pages has been configured
    unless Page.news_pages.any?
      redirect_to admin_pages_url(@language) and return
    end

    count_options = {
      :drafts        => true,
      :hidden        => true,
      :all_languages => true,
      :autopublish   => true,
      :language      => @language,
      :parent        => @news_pages.to_a
    }

    # Are we queried by category?
    if params[:category]
      @category = Category.find_by_slug(params[:category].to_s)
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

  def reorder_pages
    pages = params[:ids].map{|id| Page.find(id)}
    PagesCore::CacheSweeper.once do
      pages.each_with_index do |page, index|
        page.update_attribute(:position, (index + 1))
      end
    end
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

  # TODO: Should be refactored
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
      redirect_to edit_admin_page_url(@language, @page)
    else
      render :action => :new
    end
  end

  def edit
    @authors = User.find(:all, :order => 'realname', :conditions => {:is_activated => true})
    # Make sure the page author is included in the dropdown
    # even if the account isn't active.
    if @authors.any? && @page.author
      @authors = [@page.author] + @authors.reject{|a| a == @page.author}
    end
    @new_image ||= Image.new
  end

  def update
    params[:page].delete(:image) if params[:page].has_key?(:image) && params[:page][:image].blank?
    if @page.update_attributes(params[:page])
      @page.categories = (params[:category] && params[:category].length > 0) ? params[:category].map{|k,v| Category.find(k.to_i)} : []
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
    @page.flag_as_deleted!
    redirect_to admin_pages_url(:language => @language)
  end

  def delete_comment
    @comment = @page.comments.select{|c| c.id == params[:comment_id].to_i}.first
    if @comment
      @comment.destroy
      flash[:notice] = "Comment deleted"
    end
    redirect_to edit_admin_page_url(:language => @language, :id => @page, :anchor => 'comments')
  end

  def reorder
    if params[:direction] == "up"
      @page.move_higher
    elsif params[:direction] == "down"
      @page.move_lower
    end
    redirect_to admin_pages_url(:language => @language)
  end

  private

  def page_params
    params[:page]
  end

  def find_page
    begin
      @page = Page.find(params[:id]).translate(@language)
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Cannot load page with id ##{params[:id]}"
      redirect_to admin_pages_url(:language => @language) and return
    end
  end

  def find_categories
    @categories = Category.find(:all, :order => [:name])
  end

  def find_news_pages
    @news_pages = Page.news_pages.localized(@language)
    if !@news_pages.any?
      redirect_to admin_pages_url(:language => @language) and return
    end
  end

end
