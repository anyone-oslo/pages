# encoding: utf-8

class Admin::PageImagesController < Admin::AdminController

  before_action :find_page
  before_action :find_page_image, :only => [:show, :edit, :update, :destroy]

  require_authorization PageImage, proc { @page_image },
                        collection: [:index, :reorder, :new, :create]

  def index
    @page_images = @page.page_images
    respond_to do |format|
      format.json do
        render json: page_images_as_json(@page_images)
      end
    end
  end

  def reorder
    @page_images = params[:ids].map{|id| PageImage.find(id)}
    @page_images.each_with_index do |pi, i|
      pi.update(position: i)
    end
    respond_to do |format|
      format.json do
        render json: page_images_as_json(@page_images)
      end
    end
  end

  def show
  end

  def new
    @page_image = @page.page_images.new
  end

  def create
    if page_images_params?
      page_images_params.each do |index, attributes|
        if attributes[:image]
          @page.page_images.create(attributes)
        end
      end
    else
      @page.page_images.create(page_image_params)
    end
    redirect_to admin_page_path(@locale, @page, anchor: 'images') and return
  end

  def update
    if @page_image.update(page_image_params)

      # Empty the cache
      #PagesCore::CacheSweeper.sweep_image!(@page_image.image_id)

      respond_to do |format|
        format.html do
          flash[:notice] = "The image was updated"
          redirect_to admin_page_path(@locale, @page, anchor: 'images') and return
        end
        format.json do
          render :json => @page_image.to_json
        end
      end
    else
      render :action => :edit
    end
  end

  def destroy
    @page_image.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = "The image was deleted"
        redirect_to admin_page_path(@locale, @page, anchor: 'images') and return
      end
      format.json do
        render :json => @page_image.to_json
      end
    end
  end

  protected

  def find_page
    begin
      @page = Page.find(params[:page_id])
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Could not find Page with ID ##{params[:page_id]}"
      redirect_to admin_pages_path(@locale) and return
    end
  end

  def find_page_image
    begin
      @page_image = @page.page_images.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Could not find PageImage with ID ##{params[:id]}"
      redirect_to admin_page_path(@locale, @page) and return
    end
  end

  def page_image_params
    params.require(:page_image).permit(:image, :primary, :name, :description, :byline, :crop_start, :crop_size)
  end

  def page_images_params
    params.permit(page_images: [:image, :primary, :name, :description, :byline, :crop_start, :crop_size])[:page_images]
  end

  def page_images_params?
    params[:page_images] ? true : false
  end

  def page_images_as_json(page_images)
    '[' + page_images.map{|pi| pi.to_json}.join(', ') + ']'
  end

end
