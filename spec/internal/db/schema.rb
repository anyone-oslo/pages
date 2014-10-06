# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141006181300) do

  create_table "binaries", force: true do |t|
    t.string "sha1_hash"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["slug"], name: "index_categories_on_slug", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  create_table "images", force: true do |t|
    t.string   "name"
    t.string   "byline"
    t.text     "description"
    t.string   "filename",       null: false
    t.string   "content_type",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_hash",   null: false
    t.integer  "content_length", null: false
    t.string   "colorspace",     null: false
    t.integer  "real_width",     null: false
    t.integer  "real_height",    null: false
    t.integer  "crop_width"
    t.integer  "crop_height"
    t.integer  "crop_start_x"
    t.integer  "crop_start_y"
    t.integer  "crop_gravity_x"
    t.integer  "crop_gravity_y"
  end

  create_table "localizations", force: true do |t|
    t.integer  "localizable_id"
    t.string   "localizable_type"
    t.string   "name"
    t.string   "locale"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "localizations", ["localizable_id", "localizable_type", "name", "locale"], name: "by_foreign_key", unique: true, using: :btree
  add_index "localizations", ["localizable_id", "localizable_type"], name: "by_association", using: :btree

  create_table "page_comments", force: true do |t|
    t.integer  "page_id"
    t.string   "remote_ip"
    t.string   "name"
    t.string   "email"
    t.string   "url"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_files", force: true do |t|
    t.integer  "page_id"
    t.integer  "position"
    t.string   "name"
    t.string   "filename",       null: false
    t.string   "content_type",   null: false
    t.integer  "content_length", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_hash",   null: false
  end

  create_table "page_images", force: true do |t|
    t.integer "page_id"
    t.integer "image_id"
    t.integer "position"
    t.boolean "primary",  default: false, null: false
  end

  add_index "page_images", ["page_id", "primary"], name: "index_page_images_on_page_id_and_primary", using: :btree
  add_index "page_images", ["page_id"], name: "index_page_images_on_page_id", using: :btree

  create_table "pages", force: true do |t|
    t.integer  "parent_page_id"
    t.integer  "position"
    t.string   "byline"
    t.string   "template"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "status",           default: 0,     null: false
    t.string   "content_order"
    t.boolean  "feed_enabled",     default: false, null: false
    t.datetime "published_at"
    t.string   "redirect_to"
    t.integer  "image_id"
    t.boolean  "comments_allowed", default: true,  null: false
    t.string   "image_link"
    t.boolean  "news_page",        default: false, null: false
    t.boolean  "autopublish",      default: false, null: false
    t.string   "unique_name"
    t.integer  "comments_count",   default: 0,     null: false
    t.datetime "last_comment_at"
    t.boolean  "pinned",           default: false, null: false
  end

  add_index "pages", ["parent_page_id"], name: "index_pages_on_parent_page_id", using: :btree
  add_index "pages", ["position"], name: "index_pages_on_position", using: :btree
  add_index "pages", ["status", "parent_page_id", "position"], name: "for_find_page", using: :btree
  add_index "pages", ["status"], name: "index_pages_on_status", using: :btree
  add_index "pages", ["user_id"], name: "index_pages_on_user_id", using: :btree

  create_table "pages_categories", id: false, force: true do |t|
    t.integer "page_id"
    t.integer "category_id"
  end

  add_index "pages_categories", ["category_id"], name: "index_pages_categories_on_category_id", using: :btree
  add_index "pages_categories", ["page_id"], name: "index_pages_categories_on_page_id", using: :btree

  create_table "password_reset_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["user_id"], name: "index_roles_on_user_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
  end

  add_index "taggings", ["tag_id"], name: "by_tag_id", using: :btree
  add_index "taggings", ["taggable_type", "taggable_id"], name: "by_taggable", using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "hashed_password"
    t.string   "name"
    t.string   "email"
    t.datetime "last_login_at"
    t.integer  "created_by"
    t.datetime "created_at"
    t.text     "persistent_data"
    t.boolean  "activated",       default: false, null: false
    t.integer  "image_id"
  end

end
