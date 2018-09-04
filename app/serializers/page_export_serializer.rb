class PageExportSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :path, :locale, :author_name, :status
  attributes(*PagesCore::Templates::TemplateConfiguration.all_blocks)
  attributes :created_at, :published_at, :pinned, :template, :redirect_to,
             :starts_at, :ends_at, :all_day

  has_one :image, serializer: PageImageExportSerializer
  has_many :images, serializer: PageImageExportSerializer
  has_many :page_files, serializer: PageFileExportSerializer

  def author_name
    object&.author&.name
  end

  def path
    object.full_path || object.to_param
  end

  def image
    object.page_images.where(primary: true).try(:first)
  end

  def images
    object.page_images
  end

  def status
    object.status_label
  end
end
