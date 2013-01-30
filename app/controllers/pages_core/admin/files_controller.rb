# encoding: utf-8

class ProxyFile < File
  attr_accessor :original_filename
  attr_accessor :content_type
end

class PagesCore::Admin::FilesController < Admin::AdminController

  layout "admin"

  before_filter :stylesheets; def stylesheets; add_stylesheet "files.css"; end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }



  def index
    list
    render :action => 'list'
  end

  def list
    @filtersets = DynamicImage.filtersets.names
    session[:admin_media_imagesize] ||= "180x150"
    @size = session[:admin_media_imagesize] = params[:size] || session[:admin_media_imagesize]
    @filterset = params[:filterset] || session[:admin_media_filterset]
    session[:admin_media_filterset] = @filterset

    @pages, @images = paginate :images, :per_page => 12
  end



  def show
    @image = Image.find(params[:id])
  end



  def new
    @image = Image.new
    render_without_layout if request.xhr?
  end



  def create
    if params[:url] != ""
      base_name = File.basename( params[:url] )
      temp_file = Rails.root.join('tmp', base_name)
      system "curl #{params[:url]} > #{temp_file}"
      params[:image][:imagefile] = File.new( temp_file )
    end
    @image = Image.new(params[:image])
    #@image.author = @current_user
    FileUtils.rm( temp_file, :force => true ) if temp_file
    if @image.save
      flash[:notice] = 'Image was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end



  def edit
    @image = Image.find(params[:id])
    @image_formats = PagesCore.config :image_formats
    render_without_layout if request.xhr?
  end



  def update
  @image = Image.find(params[:id])
  if @image.update_attributes(params[:image])
    flash[:notice] = 'Image was successfully updated.'
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end



  def destroy
    Image.find(params[:id]).destroy
    flash[:notice] = 'Image was successfully deleted.'
    redirect_to :action => 'list'
  end



  def clear_cache
    logger.warn "clear_cache is depreceated!"
    redirect_to :action => 'list'
  end

end
