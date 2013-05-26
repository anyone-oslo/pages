# encoding: utf-8

class Admin::PageFilesController < Admin::AdminController

  before_filter :find_page
  before_filter :find_page_file,   only: [:show, :edit, :update, :destroy]
  before_filter :redirect_to_page, only: [:index, :show, :new, :edit]

  def index
  end

  def reorder
    if params[:ids]
      files = Array(params[:ids]).map{ |id| PageFile.find(id) }
      files.each_with_index do |file, index|
        file.update_attributes(position: index)
      end
    end
    if request.xhr?
      render text: 'ok'
    else
      redirect_to_page
    end
  end

  def show
  end

  def new
  end

  def create
    @page_file = @page.files.new
    @page_file.update_attributes(params[:page_file].merge(locale: @locale))
    unless @page_file.valid?
      flash[:notice] = "Error uploading file!"
    end
    redirect_to_page
  end

  def edit
  end

  def update
    if @page_file.update_attributes(params[:page_file])
      flash[:notice] = "File updated"
    else
      flash[:notice] = "Error updating file!"
    end
    redirect_to_page
  end

  def destroy
    @page_file.destroy
    flash[:notice] = "File deleted"
    redirect_to_page
  end

  protected

  def redirect_to_page
    redirect_to edit_admin_page_path(@locale, @page, anchor: 'files') and return
  end

  def find_page
    begin
      @page = Page.find(params[:page_id]).localize(@locale)
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Could not find PageFile with ID ##{params[:id]}"
      redirect_to admin_pages_path(@locale) and return
    end
  end

  def find_page_file
    begin
      @page_file = @page.files.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Could not find PageFile with ID ##{params[:id]}"
      redirect_to admin_page_path(@locale, @page) and return
    end
  end

end
