# frozen_string_literal: true

class CreatePagesTables < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.string :filename, null: false
      t.string :content_type, null: false
      t.integer :content_length, null: false
      t.datetime :created_at
      t.datetime :updated_at
      t.string :content_hash, null: false
      t.integer :user_id
    end

    create_table :categories do |t|
      t.string :name
      t.string :slug
      t.integer :position
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index :slug
    end

    create_table :images do |t|
      t.string :filename, null: false
      t.string :content_type, null: false
      t.datetime :created_at
      t.datetime :updated_at
      t.string :content_hash, null: false
      t.integer :content_length, null: false
      t.string :colorspace, null: false
      t.integer :real_width, null: false
      t.integer :real_height, null: false
      t.integer :crop_width
      t.integer :crop_height
      t.integer :crop_start_x
      t.integer :crop_start_y
      t.integer :crop_gravity_x
      t.integer :crop_gravity_y
    end

    create_table :invite_roles do |t|
      t.integer :invite_id
      t.string :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :invites do |t|
      t.integer :user_id
      t.string :email
      t.string :token
      t.datetime :sent_at
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :localizations do |t|
      t.integer :localizable_id
      t.string :localizable_type
      t.string :name
      t.string :locale
      t.text :value
      t.datetime :created_at
      t.datetime :updated_at
      t.index %i[localizable_id localizable_type name locale],
              name: :index_textbits_on_locale,
              unique: true
      t.index %i[localizable_id localizable_type]
    end

    create_table :page_categories do |t|
      t.integer :page_id
      t.integer :category_id
      t.index :category_id
      t.index :page_id
    end

    create_table :page_files, force: :cascade do |t|
      t.bigint :page_id
      t.bigint :attachment_id
      t.integer :position
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index :attachment_id
      t.index :page_id
    end

    create_table :page_images do |t|
      t.integer :page_id
      t.integer :image_id
      t.integer :position
      t.boolean :primary, default: false, null: false
      t.index %i[page_id primary]
      t.index :page_id
    end

    create_table :page_paths do |t|
      t.integer :page_id
      t.string :locale
      t.string :path
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.index %i[locale path], unique: true
    end

    create_table :pages do |t|
      t.integer :parent_page_id
      t.integer :position
      t.string :byline
      t.string :template
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :user_id
      t.integer :status, default: 0, null: false
      t.boolean :feed_enabled, default: false, null: false
      t.datetime :published_at
      t.string :redirect_to
      t.integer :image_id
      t.string :image_link
      t.boolean :news_page, default: false, null: false
      t.boolean :autopublish, default: false, null: false
      t.string :unique_name
      t.datetime :last_comment_at
      t.boolean :pinned, default: false, null: false
      t.integer :meta_image_id
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :all_day, default: false, null: false
      t.index :ends_at
      t.index :parent_page_id
      t.index :position
      t.index :starts_at
      t.index %i[status parent_page_id position]
      t.index :status
      t.index :user_id
    end

    create_table :password_reset_tokens do |t|
      t.integer :user_id
      t.string :token
      t.datetime :expires_at
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :roles do |t|
      t.integer :user_id
      t.string :name
      t.datetime :created_at
      t.datetime :updated_at
      t.index :user_id
    end

    create_table :taggings do |t|
      t.integer :tag_id
      t.integer :taggable_id
      t.string :taggable_type
      t.index :tag_id
      t.index %i[taggable_type taggable_id]
    end

    create_table :tags do |t|
      t.string :name
      t.boolean :pinned, default: false, null: false
      t.index :name
    end

    create_table :users do |t|
      t.string :username
      t.string :hashed_password
      t.string :name
      t.string :email
      t.datetime :last_login_at
      t.integer :created_by
      t.datetime :created_at
      t.text :persistent_data
      t.boolean :activated, default: false, null: false
      t.integer :image_id
    end
  end
end
