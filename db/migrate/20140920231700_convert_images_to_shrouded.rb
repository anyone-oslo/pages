class ConvertImagesToShrouded < ActiveRecord::Migration
  class Image < ActiveRecord::Base; end
  class Binary < ActiveRecord::Base; end

  def change
    add_column :images, :content_hash, :string, null: false
    change_column :images, :content_type, :string, null: false
    add_column :images, :content_length, :integer, null: false
    change_column :images, :filename, :string, null: false
    add_column :images, :colorspace, :string, null: false
    add_column :images, :real_width, :integer, null: false
    add_column :images, :real_height, :integer, null: false
    add_column :images, :crop_width, :integer
    add_column :images, :crop_height, :integer
    add_column :images, :crop_start_x, :integer
    add_column :images, :crop_start_y, :integer
    add_column :images, :crop_gravity_x, :integer
    add_column :images, :crop_gravity_y, :integer

    Image.reset_column_information
    reversible do |dir|
      dir.up do
        Image.all.each do |image|
          binary = Binary.find(image.binary_id)
          hash = binary.sha1_hash

          if binary_exist?(hash)
            f = binary_file(hash)
            image.content_length = f.size
            image.content_hash = Shrouded::Storage.store("images", f)
            f.close
          else
            image.content_hash = hash
            image.content_length = 0
          end

          image.colorspace = "rgb"

          image.real_width, image.real_height = Vector2d(image.original_size).to_a

          if image.cropped?
            image.crop_start_x, image.crop_start_y = Vector2d(image.crop_start).to_a
            image.crop_width, image.crop_height = Vector2d(image.crop_size).to_a
          end

          image.save
        end
      end
    end

    remove_column :images, :folder, :integer
    remove_column :images, :user_id, :integer
    remove_column :images, :filters, :text
    remove_column :images, :original_size, :string
    remove_column :images, :hotspot, :string
    remove_column :images, :binary_id, :integer
    remove_column :images, :original_binary_id, :integer
    remove_column :images, :url, :string
    remove_column :images, :cropped, :boolean, null: false, default: false
    remove_column :images, :crop_start, :string
    remove_column :images, :crop_size, :string
  end

  private

  def binary_file(hash)
    File.open(binary_path(hash), 'rb')
  end

  def binary_exist?(hash)
    File.exist?(binary_path(hash))
  end

  def binary_path(hash)
    folder = hash[0...2]
    filename = hash[2..hash.length]
    Rails.root.join('db', 'binary-objects', Rails.env, folder, filename)
  end
end
