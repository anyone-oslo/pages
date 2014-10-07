class CreateRoles < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.belongs_to :user
      t.string :email, :token
      t.datetime :sent_at
      t.timestamps
    end

    create_table :invite_roles do |t|
      t.belongs_to :invite
      t.string :name
      t.timestamps
    end
  end
end