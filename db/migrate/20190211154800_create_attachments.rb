class CreateAttachments < ActiveRecord::Migration[5.2]
  def up
    rename_table :page_files, :attachments
    add_column :attachments, :user_id, :integer

    create_table :page_files do |t|
      t.references :page
      t.references :attachment
      t.integer :position
      t.timestamps
    end

    Attachment.reset_column_information
    PageFile.reset_column_information

    locales = [I18n.default_locale,
               PagesCore.config.locales&.keys].flatten.compact.map(&:to_sym).uniq

    Attachment.all.each do |a|
      begin
        Dis::Storage.change_type("page_files", "attachments", a.content_hash)
      rescue
        puts "Missing attachment: #{a.content_hash}"
      end
      locales.each do |l|
        Localization.create(localizable: a,
                            locale: l,
                            name: "name",
                            value: a.attributes["name"])
      end
      PageFile.create(attachment_id: a.id,
                      page_id: a.page_id,
                      position: a.position,
                      created_at: a.created_at,
                      updated_at: a.updated_at)
    end

    Localization.where(localizable_type: "PageFile")
                .update_all(localizable_type: "Attachment")

    remove_column :attachments, :page_id
    remove_column :attachments, :position
    remove_column :attachments, :name
  end

  def down
    add_column :attachments, :name, :string
    add_column :attachments, :position, :integer
    add_column :attachments, :page_id, :integer

    Attachment.reset_column_information
    Attachment.all.in_locale(I18n.default_locale).each do |a|
      begin
        Dis::Storage.change_type("attachments", "page_files", a.content_hash)
      rescue
        puts "Missing attachment: #{a.content_hash}"
      end

      pf = PageFile.find_by(attachment_id: a.id)
      Attachment.where(id: a.id).update_all(name: a.name,
                                            page_id: pf.page_id,
                                            position: pf.position)
    end

    Localization.where(localizable_type: "Attachment")
                .update_all(localizable_type: "PageFile")
    Localization.where(localizable_type: "PageFile", name: "name").destroy_all

    drop_table :page_files
    remove_column :attachments, :user_id
    rename_table :attachments, :page_files
  end
end
