# frozen_string_literal: true

module PagesCore
  module AttachmentsHelper
    def attachment_path(*args)
      super(*attachment_params(args))
    end

    def download_attachment_path(*args)
      super(*attachment_params(args))
    end

    private

    def attachment_params(args)
      attachment = args.detect { |a| a.is_a?(Attachment) }
      args = [attachment.digest] + args if args.first == attachment
      if args.last.is_a?(Hash)
        args.last[:format] = attachment.filename_extension
      else
        args.push(format: attachment.filename_extension)
      end
      args
    end

    def attachment_digest(attachment)
      Attachment.verifier.generate(attachment.id.to_s)
    end
  end
end
