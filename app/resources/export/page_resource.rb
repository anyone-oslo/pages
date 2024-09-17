# frozen_string_literal: true

module Export
  class PageResource
    include Alba::Resource

    attributes :id, :locale
    attributes(*PagesCore::Templates::TemplateConfiguration.all_blocks)
    attributes :created_at, :published_at, :pinned, :template, :redirect_to,
               :starts_at, :ends_at, :all_day, :skip_index

    has_many :attachments, resource: Export::AttachmentResource

    attribute :author_name do
      object&.author&.name
    end

    attribute :path do
      object.full_path || object.to_param
    end

    attribute :image do
      image_resource(object.page_images.where(primary: true).try(:first))
    end

    attribute :images do
      object.page_images.map { |image| image_resource(image) }
    end

    attribute :status do
      object.status_label
    end

    private

    def image_resource(image)
      return nil unless image

      Export::PageImageResource.new(image)
    end
  end
end
