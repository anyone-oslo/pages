# frozen_string_literal: true

module PagesCore
  class DestroyInviteService
    attr_reader :invite

    def initialize(invite:)
      @invite = invite
    end

    class << self
      def call(invite:)
        new(invite: invite).call
      end
    end

    def call
      Invite.transaction do
        invite.destroy
        PagesCore::PubSub.publish(:destroy_invite, invite: invite)
        invite
      end
    end
  end
end
