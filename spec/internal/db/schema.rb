# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_02_01_160700) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "attachments", id: :serial, force: :cascade do |t|
    t.string "filename", null: false
    t.string "content_type", null: false
    t.integer "content_length", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "content_hash", null: false
    t.integer "user_id"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.integer "position"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["slug"], name: "index_categories_on_slug"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "queue"
  end

  create_table "dynamic_image_variants", force: :cascade do |t|
    t.string "image_type", null: false
    t.bigint "image_id", null: false
    t.string "content_hash", null: false
    t.string "content_type", null: false
    t.integer "content_length", null: false
    t.string "filename", null: false
    t.string "format", null: false
    t.integer "width", null: false
    t.integer "height", null: false
    t.integer "crop_width", null: false
    t.integer "crop_height", null: false
    t.integer "crop_start_x", null: false
    t.integer "crop_start_y", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["image_id", "image_type", "format", "width", "height", "crop_width", "crop_height", "crop_start_x", "crop_start_y"], name: "dynamic_image_variants_by_format_and_size", unique: true
    t.index ["image_id", "image_type"], name: "dynamic_image_variants_by_image"
    t.index ["image_type", "image_id"], name: "index_dynamic_image_variants_on_image"
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.string "filename", null: false
    t.string "content_type", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "content_hash", null: false
    t.integer "content_length", null: false
    t.string "colorspace", null: false
    t.integer "real_width", null: false
    t.integer "real_height", null: false
    t.integer "crop_width"
    t.integer "crop_height"
    t.integer "crop_start_x"
    t.integer "crop_start_y"
    t.integer "crop_gravity_x"
    t.integer "crop_gravity_y"
  end

  create_table "invite_roles", id: :serial, force: :cascade do |t|
    t.integer "invite_id"
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "invites", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "email"
    t.string "token"
    t.datetime "sent_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "localizations", id: :serial, force: :cascade do |t|
    t.integer "localizable_id"
    t.string "localizable_type"
    t.string "name"
    t.string "locale"
    t.text "value"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["localizable_id", "localizable_type", "name", "locale"], name: "index_textbits_on_locale", unique: true
    t.index ["localizable_id", "localizable_type"], name: "index_localizations_on_localizable_id_and_localizable_type"
  end

  create_table "page_categories", id: :serial, force: :cascade do |t|
    t.integer "page_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_page_categories_on_category_id"
    t.index ["page_id"], name: "index_page_categories_on_page_id"
  end

  create_table "page_files", id: :serial, force: :cascade do |t|
    t.bigint "page_id"
    t.bigint "attachment_id"
    t.integer "position"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["attachment_id"], name: "index_page_files_on_attachment_id"
    t.index ["page_id"], name: "index_page_files_on_page_id"
  end

  create_table "page_images", id: :serial, force: :cascade do |t|
    t.integer "page_id"
    t.integer "image_id"
    t.integer "position"
    t.boolean "primary", default: false, null: false
    t.index ["page_id", "primary"], name: "index_page_images_on_page_id_and_primary"
    t.index ["page_id"], name: "index_page_images_on_page_id"
  end

  create_table "page_paths", id: :serial, force: :cascade do |t|
    t.integer "page_id"
    t.string "locale"
    t.string "path"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["locale", "path"], name: "index_page_paths_on_locale_and_path", unique: true
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.integer "parent_page_id"
    t.integer "position"
    t.string "byline"
    t.string "template"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.integer "status", default: 0, null: false
    t.boolean "feed_enabled", default: false, null: false
    t.datetime "published_at", precision: nil
    t.string "redirect_to"
    t.integer "image_id"
    t.string "image_link"
    t.boolean "news_page", default: false, null: false
    t.boolean "autopublish", default: false, null: false
    t.string "unique_name"
    t.datetime "last_comment_at", precision: nil
    t.boolean "pinned", default: false, null: false
    t.integer "meta_image_id"
    t.datetime "starts_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.boolean "all_day", default: false, null: false
    t.index ["ends_at"], name: "index_pages_on_ends_at"
    t.index ["parent_page_id"], name: "index_pages_on_parent_page_id"
    t.index ["position"], name: "index_pages_on_position"
    t.index ["starts_at"], name: "index_pages_on_starts_at"
    t.index ["status", "parent_page_id", "position"], name: "index_pages_on_status_and_parent_page_id_and_position"
    t.index ["status"], name: "index_pages_on_status"
    t.index ["user_id"], name: "index_pages_on_user_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id"], name: "index_roles_on_user_id"
  end

  create_table "search_documents", force: :cascade do |t|
    t.string "searchable_type", null: false
    t.bigint "searchable_id", null: false
    t.string "locale", null: false
    t.text "name"
    t.text "description"
    t.text "content"
    t.text "tags"
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "record_updated_at", precision: nil, null: false
    t.string "tsv_config", default: "simple_unaccent", null: false
    t.tsvector "tsv"
    t.index ["name"], name: "search_documents_trgm_idx", opclass: :gin_trgm_ops, using: :gin
    t.index ["searchable_type", "searchable_id", "locale"], name: "search_documents_unique_index", unique: true
    t.index ["searchable_type", "searchable_id"], name: "index_search_documents_on_searchable_type_and_searchable_id"
    t.index ["tsv"], name: "index_search_documents_on_tsv", using: :gin
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "pinned", default: false, null: false
    t.index ["name"], name: "index_tags_on_name"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "password_digest"
    t.string "name"
    t.citext "email"
    t.datetime "last_login_at", precision: nil
    t.integer "created_by"
    t.datetime "created_at", precision: nil
    t.boolean "activated", default: false, null: false
    t.integer "image_id"
    t.boolean "otp_enabled", default: false, null: false
    t.string "otp_secret"
    t.datetime "last_otp_at"
    t.jsonb "hashed_recovery_codes", default: [], null: false
    t.string "session_token", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
