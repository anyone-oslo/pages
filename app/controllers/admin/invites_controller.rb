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
      @invite = current_user.invites.create(invite_params)
      if @invite.valid?
        deliver_invite(@invite)
        @invite.update(sent_at: Time.now.utc)
        redirect_to admin_invites_url
      else
        render action: :new
      end
    end

    def destroy
      flash[:notice] = "The invite to #{@invite.email} has been deleted"
      @invite.destroy
      redirect_to admin_invites_url
    end

    private

    def deliver_invite(invite)
      AdminMailer.invite(
        invite,
        admin_invite_with_token_url(invite, invite.token)
      ).deliver_now
    end

    def find_invite
      @invite = Invite.find(params[:id])
    end

    def find_and_validate_invite
      @invite = Invite.find_by(id: params[:id])
      return if @invite && secure_compare(@invite.token, params[:token])
      flash[:notice] = "This invite is no longer valid."
      redirect_to(login_admin_users_url) && return
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :confirm_password)
    end

    def invite_params
      params.require(:invite).permit(:email, role_names: [])
    end
  end
end
