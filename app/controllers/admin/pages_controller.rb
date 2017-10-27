# encoding: utf-8

module Admin
  class PagesController < Admin::AdminController
    include PagesCore::Admin::NewsPageController

    before_action :find_page, only: %i[show edit preview update destroy
                                       delete_meta_image move]
    before_action :find_categories

    require_authorization(Page, proc { @page },
                          collection: %i[index news new new_news create
                                         deleted],
                          member: %i[show edit preview update destroy
                                     delete_meta_image move])

    def index
      @root_pages = Page.roots.in_locale(@locale).visible
    end

    def deleted
      @pages = Page.deleted.by_updated_at.in_locale(@locale)
    end

    def show
      redirect_to edit_admin_page_url(@locale, @page)
    end

    def new
      @page = build_page(@locale)
      @page.parent = if params[:parent]
                       Page.find(params[:parent])
                     elsif @news_pages
                       @news_pages.first
                     end
    end

    def create
      @page = build_page(@locale, page_params, param_categories)
      if @page.valid?
        @page.save
        respond_with_page(@page) do
          redirect_to(edit_admin_page_url(@locale, @page))
        end
      else
        render action: :new
      end
    end

    def edit; end

    def update
      if @page.update(page_params)
        @page.categories = param_categories
        respond_with_page(@page) do
          flash[:notice] = "Your changes were saved"
          redirect_to edit_admin_page_url(@locale, @page)
        end
      else
        render action: :edit
      end
    end

    def move
      parent = params[:parent_id] ? Page.find(params[:parent_id]) : nil
      @page.update(parent: parent, position: params[:position])
      respond_with_page(@page) { redirect_to admin_pages_url(@locale) }
    end

    def destroy
      Page.find(params[:id]).flag_as_deleted!
      redirect_to admin_pages_url(@locale)
    end

    def delete_meta_image
      @page.meta_image.destroy
      flash[:notice] = "The image was deleted"
      redirect_to edit_admin_page_url(@locale, @page, anchor: "metadata")
    end

    private

    def build_page(locale, attributes = nil, categories = nil)
      Page.new.localize(locale).tap do |page|
        page.author = default_author || current_user
        page.attributes = attributes if attributes
        page.categories = categories if categories
      end
    end

    def default_author
      User.where(email: PagesCore.config.default_author).first
    end

    def page_attributes
      %i[template user_id status feed_enabled published_at
         redirect_to image_link news_page
         unique_name pinned parent_page_id serialized_tags meta_image]
    end

    def page_params
      params.require(:page).permit(Page.localized_attributes + page_attributes)
    end

    def param_categories
      return [] unless params[:category]
      params.permit(category: {})[:category]
            .to_hash
            .map { |id, _| Category.find(id) }
    end

    def find_page
      @page = Page.find(params[:id]).localize(@locale)
    end

    def find_categories
      @categories = Category.order("name")
    end

    def respond_with_page(page)
      respond_to do |format|
        format.html { yield }
        format.json { render json: page, serializer: PageTreeSerializer }
      end
    end
  end
end
