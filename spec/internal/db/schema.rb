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

ActiveRecord::Schema.define(version: 20150904164200) do

  create_table "binaries", force: :cascade do |t|
    t.string "sha1_hash", limit: 255
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "slug",       limit: 255
    t.integer  "position",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "categories", ["slug"], name: "index_categories_on_slug", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "queue",      limit: 255
  end

  create_table "images", force: :cascade do |t|
    t.string   "filename",       limit: 255, null: false
    t.string   "content_type",   limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_hash",   limit: 255, null: false
    t.integer  "content_length", limit: 4,   null: false
    t.string   "colorspace",     limit: 255, null: false
    t.integer  "real_width",     limit: 4,   null: false
    t.integer  "real_height",    limit: 4,   null: false
    t.integer  "crop_width",     limit: 4
    t.integer  "crop_height",    limit: 4
    t.integer  "crop_start_x",   limit: 4
    t.integer  "crop_start_y",   limit: 4
    t.integer  "crop_gravity_x", limit: 4
    t.integer  "crop_gravity_y", limit: 4
  end

  create_table "invite_roles", force: :cascade do |t|
    t.integer  "invite_id",  limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invites", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "email",      limit: 255
    t.string   "token",      limit: 255
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "localizations", force: :cascade do |t|
    t.integer  "localizable_id",   limit: 4
    t.string   "localizable_type", limit: 255
    t.string   "name",             limit: 255
    t.string   "locale",           limit: 255
    t.text     "value",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "localizations", ["localizable_id", "localizable_type", "name", "locale"], name: "by_foreign_key", unique: true, using: :btree
  add_index "localizations", ["localizable_id", "localizable_type"], name: "by_association", using: :btree

  create_table "page_comments", force: :cascade do |t|
    t.integer  "page_id",    limit: 4
    t.string   "remote_ip",  limit: 255
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.string   "url",        limit: 255
    t.text     "body",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_files", force: :cascade do |t|
    t.integer  "page_id",        limit: 4
    t.integer  "position",       limit: 4
    t.string   "name",           limit: 255
    t.string   "filename",       limit: 255, null: false
    t.string   "content_type",   limit: 255, null: false
    t.integer  "content_length", limit: 4,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_hash",   limit: 255, null: false
  end

  create_table "page_images", force: :cascade do |t|
    t.integer "page_id",  limit: 4
    t.integer "image_id", limit: 4
    t.integer "position", limit: 4
    t.boolean "primary",  limit: 1, default: false, null: false
  end

  add_index "page_images", ["page_id", "primary"], name: "index_page_images_on_page_id_and_primary", using: :btree
  add_index "page_images", ["page_id"], name: "index_page_images_on_page_id", using: :btree

  create_table "pages", force: :cascade do |t|
    t.integer  "parent_page_id",   limit: 4
    t.integer  "position",         limit: 4
    t.string   "byline",           limit: 255
    t.string   "template",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",          limit: 4
    t.integer  "status",           limit: 4,   default: 0,     null: false
    t.string   "content_order",    limit: 255
    t.boolean  "feed_enabled",     limit: 1,   default: false, null: false
    t.datetime "published_at"
    t.string   "redirect_to",      limit: 255
    t.integer  "image_id",         limit: 4
    t.boolean  "comments_allowed", limit: 1,   default: true,  null: false
    t.string   "image_link",       limit: 255
    t.boolean  "news_page",        limit: 1,   default: false, null: false
    t.boolean  "autopublish",      limit: 1,   default: false, null: false
    t.string   "unique_name",      limit: 255
    t.integer  "comments_count",   limit: 4,   default: 0,     null: false
    t.datetime "last_comment_at"
    t.boolean  "pinned",           limit: 1,   default: false, null: false
    t.integer  "meta_image_id",    limit: 4
  end

  add_index "pages", ["parent_page_id"], name: "index_pages_on_parent_page_id", using: :btree
  add_index "pages", ["position"], name: "index_pages_on_position", using: :btree
  add_index "pages", ["status", "parent_page_id", "position"], name: "for_find_page", using: :btree
  add_index "pages", ["status"], name: "index_pages_on_status", using: :btree
  add_index "pages", ["user_id"], name: "index_pages_on_user_id", using: :btree

  create_table "pages_categories", id: false, force: :cascade do |t|
    t.integer "page_id",     limit: 4
    t.integer "category_id", limit: 4
  end

  add_index "pages_categories", ["category_id"], name: "index_pages_categories_on_category_id", using: :btree
  add_index "pages_categories", ["page_id"], name: "index_pages_categories_on_page_id", using: :btree

  create_table "password_reset_tokens", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "token",      limit: 255
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["user_id"], name: "index_roles_on_user_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255
    t.text     "data",       limit: 65535
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id",        limit: 4
    t.integer "taggable_id",   limit: 4
    t.string  "taggable_type", limit: 255
  end

  add_index "taggings", ["tag_id"], name: "by_tag_id", using: :btree
  add_index "taggings", ["taggable_type", "taggable_id"], name: "by_taggable", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",   limit: 255
    t.boolean "pinned", limit: 1,   default: false, null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",        limit: 255
    t.string   "hashed_password", limit: 255
    t.string   "name",            limit: 255
    t.string   "email",           limit: 255
    t.datetime "last_login_at"
    t.integer  "created_by",      limit: 4
    t.datetime "created_at"
    t.text     "persistent_data", limit: 65535
    t.boolean  "activated",       limit: 1,     default: false, null: false
    t.integer  "image_id",        limit: 4
  end

end
