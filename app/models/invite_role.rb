class InviteRole < ActiveRecord::Base
  belongs_to :invite
  validates :name,
            presence:   true,
            uniqueness: { scope: :invite_id },
            inclusion:  { in: Proc.new { Role.roles.map(&:name) } }

  def to_s
    self.name.humanize
  end
end