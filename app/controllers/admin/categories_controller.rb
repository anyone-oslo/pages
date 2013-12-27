# encoding: utf-8

class Admin::CategoriesController < Admin::AdminController
  before_filter :find_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = Category.all
  end

  def show
    redirect_to edit_admin_category_url(@category)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.create(category_params)
    if @category.valid?
      flash[:notice] = "New category created"
      redirect_to admin_pages_url(@locale)
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @category.update_attributes(category_params)
      flash[:notice] = "Category was updated"
      redirect_to admin_pages_url(@locale)
    else
      render action: :edit
    end
  end

  def destroy
    @category.destroy
    flash[:notice] = "Category was deleted"
    redirect_to admin_pages_url(@locale)
  end

  protected

  def category_params
    params.require(:category).permit(:name, :slug, :position)
  end

  def find_category
    begin
      @category = Category.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "Could not find Category with ID ##{params[:id]}"
      redirect_to admin_pages_url(@locale) and return
    end
  end
end
