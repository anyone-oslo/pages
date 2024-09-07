# frozen_string_literal: true

class AttachmentsController < ApplicationController
  include PagesCore::RangedResponse

  before_action :verify_signed_params
  before_action :find_attachment, only: %i[show download]

  static_cache :show, permanent: true

  def show
    send_attachment
  end

  def download
    send_attachment disposition: "attachment"
  end

  private

  def find_attachment
    @attachment = Attachment.find(params[:id])
  end

  def send_attachment(disposition: "inline")
    unless stale?(etag: @attachment, last_modified: @attachment.updated_at)
      return
    end

    send_ranged_data(@attachment.data,
                     filename: @attachment.filename,
                     type: @attachment.content_type,
                     disposition:)
  end

  def verify_signed_params
    key = params[:id].to_i.to_s
    Attachment.verifier.verify(key, params[:digest])
  end
end
