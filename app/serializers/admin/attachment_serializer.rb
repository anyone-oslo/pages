module Admin
  class AttachmentSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers
    include PagesCore::AttachmentHelper

    attributes :id, :filename, :content_type, :content_hash, :content_length,
               :name, :description, :created_at, :updated_at, :url

    def name
      localized_attribute(:name)
    end

    def description
      localized_attribute(:description)
    end

    def url
      attachment_path(object)
    end

    private

    def localized_attribute(attr)
      object.locales.each_with_object({}) do |locale, hash|
        hash[locale] = object.localize(locale).send(attr)
      end
    end
  end
end
