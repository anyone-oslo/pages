# frozen_string_literal: true

class Attachment < ApplicationRecord
  include Dis::Model
  include PagesCore::Sweepable

  belongs_to :user, optional: true

  validates_data_presence
  validates :content_type, presence: true
  validates :filename, presence: true
  validates :content_length, presence: true

  localizable do
    attribute :name
    attribute :description
  end

  before_validation :set_name_from_filename

  class << self
    def verifier
      @verifier ||= PagesCore::DigestVerifier.new(
        Rails.application.key_generator.generate_key("attachments")
      )
    end

    def formats
      {
        "audio/mpeg" => :mp3,
        "image/gif" => :gif,
        "image/jpeg" => :jpg,
        "image/jpg" => :jpg,
        "image/pjpeg" => :jpg,
        "image/png" => :png,
        "application/pdf" => :pdf
      }
    end
  end

  def digest
    return unless id

    self.class.verifier.generate(id.to_s)
  end

  def format?
    content_type && self.class.formats.key?(content_type)
  end

  def format
    self.class.formats[content_type]
  end

  def filename_extension
    if filename_extension?
      filename.match(/\.([^.]+)$/)[1]
    else
      ""
    end
  end

  def filename_extension?
    filename.include?(".")
  end

  # Includes a timestamp fingerprint in the URL param, so
  # that rendered images can be cached indefinitely.
  def to_param
    [id, updated_at.utc.to_fs(cache_timestamp_format)].join("-")
  end

  private

  def set_name_from_filename
    self.name ||= File.basename(filename, ".*") if filename? && locale
  end
end
