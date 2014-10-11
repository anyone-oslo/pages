# encoding: utf-8

class Admin::PageCommentsController < Admin::AdminController
  before_action :find_page
  before_action :find_page_comment, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to admin_page_path(@locale, @page)
  end

  def show
  end

  def new
    @page_comment = @page.comments.new
  end

  def edit
  end

  def create
    @page_comment = @page.comments.create(page_comment_params)
    if @page_comment.valid?
      flash[:notice] = "The comment was created"
      redirect_to admin_page_path(@locale, @page)
    else
      render action: :new
    end
  end

  def update
    if @page_comment.update(page_comment_params)
      flash[:notice] = "The comment was updated"
      redirect_to admin_page_path(@locale, @page)
    else
      render action: :edit
    end
  end

  def destroy
    @page_comment.destroy
    flash[:notice] = "The comment was deleted"
    redirect_to admin_page_path(@locale, @page)
  end

  protected

  def find_page
    @page = Page.find(params[:page_id])
  end

  def find_page_comment
    @page_comment = @page.comments.find(params[:id])
  end

  def page_comment_params
    params.require(:page_comment).permit(:name, :email, :url, :body)
  end
end
