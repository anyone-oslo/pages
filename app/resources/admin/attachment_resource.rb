# frozen_string_literal: true

module Admin
  class AttachmentResource
    include Alba::Resource
    include Rails.application.routes.url_helpers
    include PagesCore::AttachmentsHelper

    attributes :id, :filename, :content_type, :content_hash, :content_length,
               :created_at, :updated_at

    attribute :name do
      localized_attribute(:name)
    end

    attribute :description do
      localized_attribute(:description)
    end

    attribute :url do
      attachment_path(object)
    end

    private

    def localized_attribute(attr)
      object.locales.index_with do |locale|
        object.localize(locale).send(attr)
      end
    end
  end
end
