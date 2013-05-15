# encoding: utf-8

class PagesCore::Admin::PageFilesController < Admin::AdminController

  before_filter :load_page
  before_filter :load_page_file, :only => [:show, :edit, :update, :destroy]

  protected

    def load_page
      begin
        @page = Page.find(params[:page_id]).localize(@locale)
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Could not find PageFile with ID ##{params[:id]}"
        redirect_to admin_pages_path(@locale) and return
      end
    end

    def load_page_file
      begin
        @page_file = @page.files.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Could not find PageFile with ID ##{params[:id]}"
        redirect_to admin_page_path(@locale, @page) and return
      end
    end

  public

    def index
      redirect_to edit_admin_page_path(@locale, @page, anchor: 'files')
    end

    def reorder
      if params[:ids]
        Array(params[:ids]).map{ |id| PageFile.find(id) }.each_with_index do |file, index|
          file.update_attributes(position: index)
        end
      end
      if request.xhr?
        render :text => 'ok' and return
      else
        redirect_to edit_admin_page_path(@locale, @page, anchor: 'files')
      end
    end

    def show
      redirect_to edit_admin_page_path(@locale, @page, anchor: 'files')
    end

    def new
      redirect_to edit_admin_page_path(@locale, @page, anchor: 'files')
    end

    def create
      @page_file = @page.files.new
      @page_file.update_attributes(params[:page_file].merge(locale: @locale))
      unless @page_file.valid?
        flash[:notice] = "Error uploading file!"
      end
      redirect_to edit_admin_page_path(@locale, @page, anchor: 'files')
    end

    def edit
      redirect_to edit_admin_page_path(@locale, @page, anchor: 'files')
    end

    def update
      if @page_file.update_attributes(params[:page_file])
        flash[:notice] = "File updated"
      else
        flash[:notice] = "Error updating file!"
      end
      redirect_to edit_admin_page_path(@locale, @page, anchor: 'files')
    end

    def destroy
      @page_file.destroy
      flash[:notice] = "File deleted"
      redirect_to edit_admin_page_path(@locale, @page, anchor: 'files')
    end

end
