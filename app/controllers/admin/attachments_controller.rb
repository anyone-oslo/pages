module Admin
  class AttachmentController < Admin::AdminController
    before_action :find_attachment, only: %i[update]

    def create
      @attachment = Attachment.create(
        attachment_params.merge(user: current_user)
      )
      return unless @attachment.valid?

      respond_to do |format|
        format.json do
          render_attachment(@attachment)
        end
      end
    end

    def update
      @attachment.update(attachment_params)
      respond_to do |format|
        format.json { render_attachment(@attachment) }
      end
    end

    protected

    def attachment_params
      params.require(:attachment).permit(
        :file,
        localized_attributes.each_with_object({}) do |a, h|
          h[a] = I18n.available_locales
        end
      )
    end

    def localized_attributes
      %i[name description]
    end

    def find_attachment
      @attachment = Attachment.find(params[:id])
    end

    def render_attachment(attachment)
      render json: attachment, serializer: Admin::AttachmentSerializer
    end
  end
end
