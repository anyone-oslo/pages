class ConvertPageFilesToDis < ActiveRecord::Migration
  class PageFile < ActiveRecord::Base; end
  class Binary < ActiveRecord::Base; end

  def change
    add_column :page_files, :content_hash, :string, null: false
    change_column :page_files, :content_type, :string, null: false
    rename_column :page_files, :filesize, :content_length
    change_column :page_files, :content_length, :integer, null: false
    change_column :page_files, :filename, :string, null: false

    PageFile.reset_column_information
    reversible do |dir|
      dir.up do
        PageFile.all.each do |page_file|
          binary = Binary.find(page_file.binary_id)
          hash = binary.sha1_hash

          if binary_exist?(hash)
            f = binary_file(hash)
            page_file.content_hash = Dis::Storage.store("page_files", f)
            f.close
          else
            page_file.content_hash = hash
          end

          page_file.save
        end
      end
    end

    remove_column :page_files, :binary_id, :integer
  end

  private

  def binary_file(hash)
    File.open(binary_path(hash), "rb")
  end

  def binary_exist?(hash)
    File.exist?(binary_path(hash))
  end

  def binary_path(hash)
    folder = hash[0...2]
    filename = hash[2..hash.length]
    Rails.root.join("db", "binary-objects", Rails.env, folder, filename)
  end
end
