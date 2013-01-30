# encoding: utf-8

class PagesCore::Admin::ImagesController < Admin::AdminController

  def load_image
    unless @image = Image.find(params[:id]) rescue nil
      flash[:error] = "Cannot load Image with ID #{params[:id]}"
      redirect_to admin_pages_url and return
    end
  end
  protected     :load_image
  before_filter :load_image, :only => [ :show, :edit, :update, :destroy ]

  def index
  end

  def show
    respond_to do |format|
      format.js { render :text => @image.to_json, :layout => false }
    end
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
    @image.update_attributes(params[:image])
    respond_to do |format|
      format.json { render :text => @image.to_json, :layout => false }
    end
  end

  def destroy
  end

end
