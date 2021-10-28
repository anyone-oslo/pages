# frozen_string_literal: true

class PageResource
  include Alba::Resource

  attributes :id, :parent_page_id, :locale
  attributes(*PagesCore::Templates::TemplateConfiguration.all_blocks)
  attributes :published_at, :pinned

  attribute :param do
    object.to_param
  end

  attribute :image do
    image_resource(object.page_images.where(primary: true).try(:first))
  end

  attribute :images do
    object.page_images.map { |image| image_resource(image) }
  end

  attribute :pages do
    object.pages.map { |p| PageResource.new(p) }
  end

  private

  def image_resource(image)
    return nil unless image

    PageImageResource.new(image)
  end
end
