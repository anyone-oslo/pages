class Admin::InvitesController < Admin::AdminController
  before_action :require_authentication, except: [:accept]
  before_action :find_invite,            only: [:show, :edit, :update, :destroy, :accept]

  require_authorization Invite, proc { @invite },
                        member:     [:show, :edit, :update, :destroy],
                        collection: [:index, :new, :create]

  def index
    redirect_to admin_users_url
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
      # TODO: send email
      @invite.update(sent_at: Time.now)
      redirect_to admin_invites_url
    else
      render action: :new
    end
  end

  def destroy
    flash[:notice] = "The invite to <em>#{@invite.email}</em> has been deleted"
    @invite.destroy
    redirect_to admin_invites_url
  end

  private

  def find_invite
    @invite = Invite.find(params[:id])
  end

  def invite_params
    params.require(:invite).permit(:email, role_names: [])
  end
end