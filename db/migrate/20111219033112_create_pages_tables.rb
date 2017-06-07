# encoding: utf-8

class CreatePagesTables < ActiveRecord::Migration[4.2]
  def change
    create_table "accounts" do |t|
      t.string "name"
      t.string "plan"
      t.string "key"
      t.text "billing_address"
      t.integer "account_holder_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "last_billed_at"
      t.boolean "is_activated", default: true, null: false
      t.string "domain"
    end

    create_table "binaries" do |t|
      t.string "sha1_hash"
    end

    create_table "categories" do |t|
      t.string "name"
      t.string "slug"
      t.integer "position"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "categories", ["slug"]

    create_table "delayed_jobs" do |t|
      t.integer "priority",   default: 0
      t.integer "attempts",   default: 0
      t.text "handler"
      t.string "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string "locked_by"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "feed_items" do |t|
      t.integer "feed_id"
      t.string "guid"
      t.string "title"
      t.string "link"
      t.text "description"
      t.datetime "pubdate"
      t.string "author"
    end

    add_index "feed_items", ["feed_id"]

    create_table "feeds" do |t|
      t.string "url"
      t.string "link"
      t.string "title"
      t.text "description"
      t.datetime "refreshed_at"
    end

    add_index "feeds", ["url"]

    create_table "images" do |t|
      t.string "name"
      t.string "byline"
      t.text "description"
      t.string "filename"
      t.string "content_type"
      t.integer "folder"
      t.integer "user_id"
      t.datetime "created_at"
      t.text "filters"
      t.string "original_size"
      t.string "hotspot"
      t.integer "binary_id"
      t.string "url"
      t.boolean "cropped", default: false, null: false
      t.string "crop_start"
      t.string "crop_size"
      t.integer "original_binary_id"
      t.datetime "updated_at"
    end

    create_table "images_imagesets" do |t|
      t.integer "relation_id"
      t.integer "imageset_id"
      t.integer "image_id"
      t.integer "position"
    end

    create_table "imagesets" do |t|
      t.string "name"
      t.text "description"
      t.datetime "created_at"
      t.integer "user_id"
    end

    create_table "mail_subscribers" do |t|
      t.string "email"
      t.datetime "created_at"
      t.string "group", default: "Default"
    end

    create_table "mailings" do |t|
      t.string "recipients"
      t.string "sender"
      t.string "subject"
      t.text "body"
      t.datetime "created_at"
      t.boolean "failed", default: false
      t.string "content_type"
      t.boolean "in_progress", default: false, null: false
    end

    create_table "mailouts" do |t|
      t.string "subject"
      t.string "sender"
      t.string "template"
      t.text "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "image_id"
      t.text "groups"
      t.string "host"
    end

    create_table "page_comments" do |t|
      t.integer "page_id"
      t.string "remote_ip"
      t.string "name"
      t.string "email"
      t.string "url"
      t.text "body"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "page_files" do |t|
      t.integer "page_id"
      t.integer "position"
      t.string "name"
      t.string "filename"
      t.string "content_type"
      t.integer "filesize"
      t.integer "binary_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "page_images" do |t|
      t.integer "page_id"
      t.integer "image_id"
      t.integer "position"
      t.boolean "primary", default: false, null: false
    end

    add_index "page_images", %w[page_id primary]
    add_index "page_images", ["page_id"]

    create_table "pages" do |t|
      t.integer "parent_page_id"
      t.integer "position"
      t.string "byline"
      t.string "template"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "user_id"
      t.integer "status", default: 0, null: false
      t.string "content_order"
      t.boolean "feed_enabled", default: false, null: false
      t.datetime "published_at"
      t.text "redirect_to"
      t.integer "image_id"
      t.boolean "comments_allowed", default: true, null: false
      t.string "image_link"
      t.boolean "news_page", default: false, null: false
      t.boolean "autopublish", default: false, null: false
      t.string "unique_name"
      t.integer "comments_count", default: 0, null: false
      t.datetime "last_comment_at"
      t.boolean "pinned", default: false, null: false
    end

    add_index "pages", ["parent_page_id"]
    add_index "pages", ["position"]
    add_index "pages", %w[status parent_page_id position]
    add_index "pages", ["status"]
    add_index "pages", ["user_id"]

    create_table "pages_categories", id: false do |t|
      t.integer "page_id"
      t.integer "category_id"
    end

    add_index "pages_categories", ["category_id"]
    add_index "pages_categories", ["page_id"]

    create_table "partials" do |t|
      t.string "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "sessions" do |t|
      t.string "session_id"
      t.text "data"
      t.datetime "updated_at"
    end

    add_index "sessions", ["session_id"]
    add_index "sessions", ["updated_at"]

    create_table "sms_subscribers" do |t|
      t.string "msisdn"
      t.string "group", default: "Default"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "taggings" do |t|
      t.integer "tag_id"
      t.integer "taggable_id"
      t.string "taggable_type"
    end

    add_index "taggings", ["tag_id"]
    add_index "taggings", %w[taggable_type taggable_id]

    create_table "tags" do |t|
      t.string "name"
    end

    add_index "tags", ["name"]

    create_table "textbits" do |t|
      t.integer "textable_id"
      t.string "textable_type"
      t.string "name"
      t.string "language"
      t.string "filter"
      t.text "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index(%w[textable_id textable_type name language],
              unique: true,
              name: "index_textbits_on_locale")
      t.index %w[textable_id textable_type]
    end

    create_table "users" do |t|
      t.string "username"
      t.string "hashed_password"
      t.string "realname"
      t.string "email"
      t.datetime "last_login_at"
      t.integer "created_by"
      t.datetime "created_at"
      t.boolean "is_admin"
      t.text "persistent_data"
      t.boolean "sms_sender"
      t.boolean "is_activated", default: false, null: false
      t.boolean "is_deleted", default: false, null: false
      t.string "token"
      t.date "born_on"
      t.string "mobile"
      t.string "web_link"
      t.integer "image_id"
      t.boolean "is_reviewer", default: false, null: false
      t.boolean "is_super_admin", default: false, null: false
      t.string "openid_url"
    end
  end
end
