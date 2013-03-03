# encoding: utf-8

# This file is auto-generated from the current state of the database. Instead of editing this file,
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120621112244) do

  create_table "album_images", :force => true do |t|
    t.integer  "album_id"
    t.integer  "image_id"
    t.integer  "position"
    t.datetime "created_at"
  end

  create_table "albums", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "binaries", :force => true do |t|
    t.string "sha1_hash"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["slug"], :name => "index_categories_on_slug"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string "name"
    t.string "location"
    t.date   "start_on"
    t.date   "end_on"
  end

  create_table "images", :force => true do |t|
    t.string   "name"
    t.string   "byline"
    t.text     "description"
    t.string   "filename"
    t.string   "content_type"
    t.integer  "folder"
    t.integer  "user_id"
    t.datetime "created_at"
    t.text     "filters"
    t.string   "original_size"
    t.string   "hotspot"
    t.integer  "binary_id"
    t.string   "url"
    t.boolean  "cropped",            :default => false, :null => false
    t.string   "crop_start"
    t.string   "crop_size"
    t.integer  "original_binary_id"
    t.datetime "updated_at"
  end

  create_table "images_imagesets", :force => true do |t|
    t.integer "relation_id"
    t.integer "imageset_id"
    t.integer "image_id"
    t.integer "position"
  end

  create_table "imagesets", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.integer  "user_id"
  end

  create_table "page_comments", :force => true do |t|
    t.integer  "page_id"
    t.string   "remote_ip"
    t.string   "name"
    t.string   "email"
    t.string   "url"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_files", :force => true do |t|
    t.integer  "page_id"
    t.integer  "position"
    t.string   "name"
    t.string   "filename"
    t.string   "content_type"
    t.integer  "filesize"
    t.integer  "binary_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_images", :force => true do |t|
    t.integer "page_id"
    t.integer "image_id"
    t.integer "position"
    t.boolean "primary",  :default => false, :null => false
  end

  add_index "page_images", ["page_id", "primary"], :name => "index_page_images_on_page_id_and_primary"
  add_index "page_images", ["page_id"], :name => "index_page_images_on_page_id"

  create_table "pages", :force => true do |t|
    t.integer  "parent_page_id"
    t.integer  "position"
    t.string   "byline"
    t.string   "template"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "status",           :default => 0,     :null => false
    t.string   "content_order"
    t.boolean  "feed_enabled",     :default => false, :null => false
    t.datetime "published_at"
    t.text     "redirect_to"
    t.integer  "image_id"
    t.boolean  "comments_allowed", :default => true,  :null => false
    t.string   "image_link"
    t.boolean  "news_page",        :default => false, :null => false
    t.boolean  "autopublish",      :default => false, :null => false
    t.boolean  "delta",            :default => false, :null => false
    t.string   "unique_name"
    t.integer  "comments_count",   :default => 0,     :null => false
    t.datetime "last_comment_at"
  end

  add_index "pages", ["delta"], :name => "delta_index"
  add_index "pages", ["parent_page_id"], :name => "index_pages_on_parent_page_id"
  add_index "pages", ["position"], :name => "index_pages_on_position"
  add_index "pages", ["status", "parent_page_id", "position"], :name => "for_find_page"
  add_index "pages", ["status"], :name => "index_pages_on_status"
  add_index "pages", ["user_id"], :name => "index_pages_on_user_id"

  create_table "pages_categories", :id => false, :force => true do |t|
    t.integer "page_id"
    t.integer "category_id"
  end

  add_index "pages_categories", ["category_id"], :name => "index_pages_categories_on_category_id"
  add_index "pages_categories", ["page_id"], :name => "index_pages_categories_on_page_id"

  create_table "production_dates", :force => true do |t|
    t.integer  "production_id"
    t.string   "venue"
    t.string   "location"
    t.string   "link"
    t.date     "event_on"
    t.boolean  "published",     :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "production_images", :force => true do |t|
    t.integer  "production_id"
    t.integer  "image_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "productions", :force => true do |t|
    t.string   "name"
    t.text     "intro"
    t.text     "body"
    t.text     "credits"
    t.text     "video_embed"
    t.boolean  "published",   :default => false, :null => false
    t.boolean  "upcoming",    :default => false, :null => false
    t.boolean  "ongoing",     :default => false, :null => false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sms_subscribers", :force => true do |t|
    t.string   "msisdn"
    t.string   "group",      :default => "Default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
  end

  add_index "taggings", ["tag_id"], :name => "by_tag_id"
  add_index "taggings", ["taggable_type", "taggable_id"], :name => "by_taggable"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"

  create_table "localizations", :force => true do |t|
    t.integer  "localizable_id"
    t.string   "localizable_type"
    t.string   "name"
    t.string   "locale"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "localizations", ["localizable_id", "localizable_type", "name", "locale"], :name => "by_foreign_key", :unique => true
  add_index "localizations", ["localizable_id", "localizable_type"], :name => "by_association"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "hashed_password"
    t.string   "realname"
    t.string   "email"
    t.datetime "last_login_at"
    t.integer  "created_by"
    t.datetime "created_at"
    t.boolean  "is_admin"
    t.text     "persistent_data"
    t.boolean  "sms_sender"
    t.boolean  "is_activated",    :default => false, :null => false
    t.boolean  "is_deleted",      :default => false, :null => false
    t.string   "token"
    t.date     "born_on"
    t.string   "mobile"
    t.string   "web_link"
    t.integer  "image_id"
    t.boolean  "is_reviewer",     :default => false, :null => false
    t.boolean  "is_super_admin",  :default => false, :null => false
    t.boolean  "delta",           :default => false, :null => false
    t.string   "openid_url"
  end

  add_index "users", ["delta"], :name => "delta_index"

end
