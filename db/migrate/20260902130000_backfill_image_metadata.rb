# frozen_string_literal: true

class BackfillImageMetadata < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  CONTENT_TYPES = { "image/jpg" => "image/jpeg",
                    "image/x-citrix-pjpeg" => "image/jpeg",
                    "image/x-png" => "image/png" }.freeze

  def up
    CONTENT_TYPES.each do |from, to|
      Image.where(content_type: from).update_all(content_type: to)
    end

    DynamicImage::Backfill.new(Image).run
  end

  def down; end
end
