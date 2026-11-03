# frozen_string_literal: true

class AttachmentsController < ApplicationController
  include Dis::Controller

  rescue_from PagesCore::DigestVerifier::InvalidSignatureError, with: :not_found

  before_action :verify_signed_params
  before_action :find_attachment, only: %i[show download]
  before_action :verify_extension, only: %i[show download]

  static_cache :show, permanent: true

  def show
    return send_attachment if @attachment.inline?

    disable_static_cache!
    send_attachment disposition: "attachment"
  end

  def download
    send_attachment disposition: "attachment"
  end

  private

  def find_attachment
    @attachment = Attachment.find(params.expect(:id))
  end

  def send_attachment(disposition: "inline")
    return unless stale?(etag: @attachment, last_modified: @attachment.updated_at)

    send_dis_data(@attachment, disposition:)
  end

  def verify_extension
    return if params[:format].to_s == @attachment.filename_extension

    not_found
  end

  def verify_signed_params
    key = params[:id].to_i.to_s
    Attachment.verifier.verify(key, params[:digest])
  end

  def not_found
    head :not_found
  end
end
