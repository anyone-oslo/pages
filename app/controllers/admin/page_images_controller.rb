module Admin
  class PageImagesController < Admin::AdminController
    before_action :find_page
    before_action :find_page_image, only: %i[show edit update destroy]

    require_authorization(
      PageImage,
      proc { @page_image },
      collection: %i[index reorder new create]
    )

    def index
      @page_images = @page.page_images
      respond_to do |format|
        format.json do
          render json: @page_images, each_serializer: Admin::PageImageSerializer
        end
      end
    end

    def reorder
      @page_images = params[:ids].map { |id| PageImage.find(id) }
      @page_images.each_with_index do |pi, i|
        pi.update(position: i + 1)
      end
      respond_to do |format|
        format.json do
          render json: @page_images, each_serializer: Admin::PageImageSerializer
        end
      end
    end

    def show; end

    def new
      @page_image = @page.page_images.new
    end

    def create
      if page_images_params?
        page_images_params.each do |_index, attributes|
          if attributes[:image]
            @page.page_images.create(attributes.merge(locale: @locale))
          end
        end
      else
        @page.page_images.create(page_image_params.merge(locale: @locale))
      end
      respond_with_page_image(@page_image)
    end

    def update
      if @page_image.update(page_image_params)
        respond_with_page_image(@page_image)
      else
        respond_to do |format|
          format.html { render action: :edit }
          format.json do
            render template: "admin/page_images/show",
                   status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @page_image.destroy
      respond_with_page_image(@page_image)
    end

    protected

    def find_page
      @page = Page.find(params[:page_id]).localize(@locale)
    end

    def find_page_image
      @page_image = @page.page_images.find(params[:id]).localize(@locale)
    end

    def page_image_params
      params.require(:page_image).permit(
        :image, :primary,
        image_attributes: %i[
          id alternative caption
          crop_start_x crop_start_y crop_width crop_height
        ]
      )
    end

    def page_images_params
      params.permit(
        page_images: [:image, :primary, {
          image_attributes: %i[alternative caption]
        }]
      )[:page_images]
    end

    def page_images_params?
      params[:page_images] ? true : false
    end

    def respond_with_page_image(page_image)
      respond_to do |format|
        format.html do
          redirect_to(admin_page_path(@locale, @page, anchor: "images"))
        end
        format.json do
          @page_image = page_image
          render template: "admin/page_images/show"
        end
      end
    end
  end
end
