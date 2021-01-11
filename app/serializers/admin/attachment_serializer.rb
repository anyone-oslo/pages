# frozen_string_literal: true

module Admin
  class AttachmentSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers
    include PagesCore::AttachmentsHelper

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
      object.locales.index_with do |locale|
        object.localize(locale).send(attr)
      end
    end
  end
end
