# frozen_string_literal: true

class PageFileExportSerializer < ActiveModel::Serializer
  attributes :id, :filename, :name, :description, :content_hash, :content_type,
             :position, :created_at
end
