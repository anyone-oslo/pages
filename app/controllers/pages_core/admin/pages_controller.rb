# encoding: utf-8

class PagesCore::Admin::PagesController < Admin::AdminController

  before_filter :require_news_pages, only: [:news]
  before_filter :find_page, only: [
    :show, :edit, :preview, :update, :destroy, :reorder,
    :delete_comment,
    :import_xml
  ]
  before_filter :find_categories
  before_filter :find_news_pages, only: [:news, :new_news]

  def index
    @root_pages = Page.roots.in_locale(@locale).visible
    respond_to do |format|
      format.html
      format.xml do
        render xml: @root_pages.to_xml(pages: true)
      end
    end
  end

  def news
    @archive_finder = Page.where(parent_page_id: @news_pages)
                          .visible
                          .order('published_at DESC')
                          .in_locale(@locale)
                          .archive_finder

    if params[:year] && params[:month]
      @year, @month = params[:year].to_i, params[:month].to_i
    else
      @year, @month = @archive_finder.latest_year_and_month
    end

    @pages = @archive_finder.by_year_and_month(@year, @month)
  end

  def list
    redirect_to admin_pages_url(@locale)
  end

  def reorder_pages
    pages = params[:ids].map{|id| Page.find(id)}
    PagesCore::CacheSweeper.once do
      pages.each_with_index do |page, index|
        page.update_attributes(position: (index + 1))
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
      @created_page = PagesCore::Serializations::PageXmlImporter.new(@page, params[:xmlfile].read).import!
    end
  end

  def new
    @page = Page.new.localize(@locale)
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
    @page = Page.new.localize(@locale)
    params[:page].delete(:image) if params[:page].has_key?(:image) && params[:page][:image].blank?
    @page.author = @current_user

    if @page.update_attributes(params[:page])
      @page.update_attributes(comments_allowed: @page.template_config.value(:comments_allowed))
      @page.categories = (params[:category] && params[:category].length > 0) ? params[:category].map{|k,v| Category.find(k.to_i)} : []
      redirect_to edit_admin_page_url(@locale, @page)
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
      redirect_to edit_admin_page_url(@locale, @page)
    else
      edit
      render :action => :edit
    end
  end

  def destroy
    @page = Page.find(params[:id])
    @page.flag_as_deleted!
    redirect_to admin_pages_url(@locale)
  end

  def delete_comment
    @comment = @page.comments.select{|c| c.id == params[:comment_id].to_i}.first
    if @comment
      @comment.destroy
      flash[:notice] = "Comment deleted"
    end
    redirect_to edit_admin_page_url(@locale, @page, anchor: 'comments')
  end

  def reorder
    if params[:direction] == "up"
      @page.move_higher
    elsif params[:direction] == "down"
      @page.move_lower
    end
    redirect_to admin_pages_url(@locale)
  end

  private

  def page_params
    params[:page]
  end

  def find_page
    begin
      @page = Page.find(params[:id]).localize(@locale)
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Cannot load page with id ##{params[:id]}"
      redirect_to admin_pages_url(@locale) and return
    end
  end

  def find_categories
    @categories = Category.find(:all, :order => [:name])
  end

  def find_news_pages
    @news_pages = Page.news_pages.in_locale(@locale)
    if !@news_pages.any?
      redirect_to admin_pages_url(@locale) and return
    end
  end

  # Redirect away if no news pages has been configured
  def require_news_pages
    unless Page.news_pages.any?
      redirect_to admin_pages_url(@locale) and return
    end
  end

end
