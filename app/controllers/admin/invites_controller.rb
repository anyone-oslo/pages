# frozen_string_literal: true

module Admin
  class InvitesController < Admin::AdminController
    before_action :require_authentication, except: %i[accept show]
    before_action :find_invite, only: %i[destroy]
    before_action :find_and_validate_invite, only: %i[show accept]

    require_authorization

    def index
      redirect_to admin_users_url
    end

    def accept
      @user = PagesCore::CreateUserService.call(user_params, invite: @invite)
      if @user.valid?
        authenticate!(@user)
        redirect_to admin_default_url
      else
        render action: :show
      end
    end

    def show
      @user = User.new(email: @invite.email)
    end

    def new
      @invite = current_user.invites.new
      Role.roles.each do |role|
        @invite.roles.new(name: role.name) if role.default
      end
    end

    def create
      @invite = PagesCore::InviteService.call(invite_params,
                                              user: current_user,
                                              host: request.host,
                                              protocol: request.protocol)
      if @invite.valid?
        redirect_to admin_invites_url
      else
        render action: :new
      end
    end

    def destroy
      flash[:notice] = "The invite to #{@invite.email} has been deleted"
      PagesCore::DestroyInviteService.call(invite: @invite)
      redirect_to admin_invites_url
    end

    private

    def find_invite
      @invite = Invite.find(params[:id])
    end

    def find_and_validate_invite
      @invite = Invite.find_by(id: params[:id])
      return if @invite && secure_compare(@invite.token, params[:token])

      flash[:notice] = t("pages_core.invite_expired")
      redirect_to(admin_login_url)
    end

    def user_params
      params.expect(user: %i[name email password password_confirmation])
    end

    def invite_params
      params.expect(invite: [:email, { role_names: [] }])
    end
  end
end
