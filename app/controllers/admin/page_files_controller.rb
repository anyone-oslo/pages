# encoding: utf-8

class Admin::PageFilesController < Admin::AdminController

  before_action :find_page
  before_action :find_page_file,   only: [:show, :edit, :update, :destroy]
  before_action :redirect_to_page, only: [:index, :show, :new, :edit]

  require_authorization PageFile, proc { @page_file },
                        collection: [:index, :reorder, :new, :create]

  def index
  end

  def reorder
    if params[:ids]
      files = Array(params[:ids]).map{ |id| PageFile.find(id) }
      files.each_with_index do |file, index|
        file.update(position: index)
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
    @page_file.update(page_file_params.merge(locale: @locale))
    unless @page_file.valid?
      flash[:notice] = "Error uploading file!"
    end
    redirect_to_page
  end

  def edit
  end

  def update
    if @page_file.update(page_file_params)
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

  def page_file_params
    params.require(:page_file).permit(:name, :filename, :file)
  end

  def redirect_to_page
    redirect_to edit_admin_page_path(@locale, @page, anchor: 'files') and return
  end

  def find_page
    @page = Page.find(params[:page_id]).localize(@locale)
  end

  def find_page_file
    @page_file = @page.files.find(params[:id])
  end

end
