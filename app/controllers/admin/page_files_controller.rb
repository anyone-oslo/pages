# encoding: utf-8

module Admin
  class PageFilesController < Admin::AdminController
    before_action :find_page
    before_action :find_page_file,   only: [:show, :edit, :update, :destroy]
    before_action :redirect_to_page, only: [:index, :show, :new, :edit]

    require_authorization(
      PageFile,
      proc { @page_file },
      collection: [:index, :reorder, :new, :create]
    )

    def index; end

    def reorder
      if params[:ids]
        files = Array(params[:ids]).map { |id| PageFile.find(id) }
        files.each_with_index { |f, i| f.update(position: i) }
      end
      if request.xhr?
        render text: "ok"
      else
        redirect_to_page
      end
    end

    def show; end

    def new; end

    def create
      @page_file = @page.files.new
      @page_file.update(page_file_params.merge(locale: @locale))
      flash[:notice] = "Error uploading file!" unless @page_file.valid?
      redirect_to_page
    end

    def edit; end

    def update
      flash[:notice] = if @page_file.update(page_file_params)
                         "File updated"
                       else
                         "Error updating file!"
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
      redirect_to(edit_admin_page_path(@locale, @page, anchor: "files"))
    end

    def find_page
      @page = Page.find(params[:page_id]).localize(@locale)
    end

    def find_page_file
      @page_file = @page.files.find(params[:id])
    end
  end
end
