# frozen_string_literal: true

module PagesCore
  class InviteService
    include Rails.application.routes.url_helpers

    attr_reader :attributes, :user, :host, :protocol

    def initialize(attributes, user:, host:, protocol: "http")
      @attributes = attributes
      @user = user
      @host = host
      @protocol = protocol
    end

    class << self
      def call(attrs, user:, host:, protocol: "http")
        new(attrs, user: user, host: host, protocol: protocol).call
      end
    end

    def call
      Invite.transaction do
        invite = user.invites.create(attributes)
        if invite.valid?
          deliver_invite(invite)
          invite.update(sent_at: Time.now.utc)
        end
        invite
      end
    end

    private

    def deliver_invite(invite)
      AdminMailer.invite(
        invite,
        admin_invite_with_token_url(invite, invite.token,
                                    host: host, protocol: protocol)
      ).deliver_later
    end
  end
end
