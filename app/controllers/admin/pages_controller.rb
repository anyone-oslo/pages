# encoding: utf-8

module Admin
  class PagesController < Admin::AdminController
    before_action :require_news_pages, only: [:news]
    before_action :find_page, only: [
      :show, :edit, :preview, :update, :destroy, :reorder
    ]
    before_action :find_categories
    before_action :find_news_pages, only: [:news, :new_news]

    require_authorization(
      Page,
      proc { @page },
      collection: [:index, :news, :new, :new_news, :create, :reorder_pages]
    )

    def index
      @root_pages = Page.roots.in_locale(@locale).visible
    end

    def news
      @archive_finder = Page.where(parent_page_id: @news_pages)
        .visible
        .order("published_at DESC")
        .in_locale(@locale)
        .archive_finder

      @year, @month = year_and_month(@archive_finder)
      @year ||= Time.now.year
      @month ||= Time.now.month

      @pages = @archive_finder.by_year_and_month(@year, @month)
    end

    def reorder_pages
      pages = params[:ids].map { |id| Page.find(id) }
      PagesCore::CacheSweeper.once do
        pages.each_with_index do |page, index|
          page.update(position: (index + 1))
        end
      end
      render text: "ok" if request.xhr?
    end

    def show
      edit
      render action: :edit
    end

    def new
      @authors = User.activated
      @page = build_page(@locale)
      if params[:parent]
        @page.parent = Page.find(params[:parent])
      elsif @news_pages
        @page.parent = @news_pages.first
      end
    end

    # TODO: Should be refactored
    def new_news
      new
      render action: :new
    end

    def create
      @page = build_page(@locale)
      if @page.update(page_params)
        @page.update(
          comments_allowed: @page.template_config.value(:comments_allowed)
        )
        @page.categories = param_categories
        redirect_to edit_admin_page_url(@locale, @page)
      else
        render action: :new
      end
    end

    def edit
      @authors = User.activated
      # Make sure the page author is included in the dropdown
      # even if the account isn't active.
      if @authors.any? && @page.author
        @authors = [@page.author] + @authors.reject { |a| a == @page.author }
      end
      @new_image ||= Image.new
    end

    def update
      if @page.update(page_params)
        @page.categories = param_categories
        flash[:notice] = "Your changes were saved"
        flash[:save_performed] = true
        redirect_to edit_admin_page_url(@locale, @page)
      else
        edit
        render action: :edit
      end
    end

    def destroy
      @page = Page.find(params[:id])
      @page.flag_as_deleted!
      redirect_to admin_pages_url(@locale)
    end

    private

    def build_page(locale)
      Page.new.localize(locale).tap do |page|
        page.author = default_author || current_user
      end
    end

    def default_author
      return unless PagesCore.config.default_author
      User.where(email: PagesCore.config.default_author).first
    end

    def permitted_page_attributes
      [
        :template, :user_id, :status, :content_order,
        :feed_enabled, :published_at, :redirect_to, :comments_allowed,
        :image_link, :news_page, :unique_name, :pinned,
        :parent_page_id, :serialized_tags
      ]
    end

    def page_params
      params.require(:page).permit(
        Page.localized_attributes + permitted_page_attributes
      )
    end

    def param_categories
      if params[:category] && params[:category].length > 0
        params[:category].map { |k, _| Category.find(k.to_i) }
      else
        []
      end
    end

    def find_page
      @page = Page.find(params[:id]).localize(@locale)
    end

    def find_categories
      @categories = Category.order("name")
    end

    def find_news_pages
      @news_pages = Page.news_pages.in_locale(@locale)
      return if @news_pages.any?
      redirect_to(admin_pages_url(@locale))
    end

    # Redirect away if no news pages has been configured
    def require_news_pages
      return if Page.news_pages.any?
      redirect_to(admin_pages_url(@locale))
    end

    def year_and_month(archive_finder)
      if params[:year] && params[:month]
        [params[:year], params[:month]].map(&:to_i)
      else
        archive_finder.latest_year_and_month
      end
    end
  end
end
