class CreateRoles < ActiveRecord::Migration[4.2]
  def connection
    @connection ||= ActiveRecord::Base.connection
  end

  def define_roles(flag, role)
    connection.select_rows(
      "SELECT id
       FROM #{connection.quote_table_name('users')}
       WHERE #{connection.quote_column_name(flag)} = #{connection.quote(true)}"
    ).each do |u|
      connection.execute(
        "INSERT INTO #{connection.quote_table_name('roles')} " \
          "(user_id, name, created_at, updated_at) " \
          "VALUES (#{u[0]}, #{connection.quote(role)}, " \
          "#{connection.quote(Time.now.utc)}, " \
          "#{connection.quote(Time.now.utc)})"
      )
    end
  end

  def undo_role(role, flag)
    connection.select_rows(
      "SELECT user_id
       FROM #{connection.quote_table_name('roles')}
       WHERE name = #{connection.quote(role)}"
    ).each do |r|
      connection.execute(
        "UPDATE #{connection.quote_table_name('users')}
         SET #{connection.quote_column_name(flag)} = #{connection.quote(true)}
         WHERE id = #{connection.quote(r[0])}"
      )
    end
  end

  def up
    create_table :roles do |t|
      t.belongs_to :user
      t.string :name
      t.timestamps
    end
    add_index :roles, :user_id

    define_roles :is_admin,    "pages"
    define_roles :is_admin,    "users"
    define_roles :is_reviewer, "reviewer"

    remove_column :users, :is_admin
    remove_column :users, :is_super_admin
    remove_column :users, :is_reviewer
    remove_column :users, :sms_sender
  end

  def down
    add_column :users, :sms_sender, :boolean, default: false, null: false
    add_column :users, :is_reviewer, :boolean, default: false, null: false
    add_column :users, :is_super_admin, :boolean, default: false, null: false
    add_column :users, :is_admin, :boolean, default: false, null: false

    undo_role "pages", :is_admin
    undo_role "users", :is_admin
    undo_role "reviewer", :is_reviewer

    drop_table :roles
  end
end
