# frozen_string_literal: true

Delayed::Worker.backend = :active_record

if Object.const_defined?("Postmark")
  class InvalidRecipientsPlugin < Delayed::Plugin
    callbacks do |lifecycle|
      lifecycle.around(:invoke_job) do |job, *args, &block|
        # Forward the call to the next callback in the callback chain
        block.call(job, *args)
      rescue Postmark::InactiveRecipientError => e
        Rails.logger.error "#{e.class}: #{e.message}"
      end
    end
  end

  Delayed::Worker.plugins << InvalidRecipientsPlugin
end
