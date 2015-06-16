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

ActiveRecord::Schema.define(version: 20150616161758) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "ad_images", force: :cascade do |t|
    t.integer  "ad_id"
    t.string   "description"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "image_fingerprint"
    t.integer  "weight"
  end

  add_index "ad_images", ["ad_id"], name: "index_ad_images_on_ad_id"

  create_table "ad_items", force: :cascade do |t|
    t.integer  "ad_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ad_items", ["ad_id"], name: "index_ad_items_on_ad_id"

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

  create_table "ads", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.decimal  "price",       precision: 10, scale: 2
    t.text     "tags"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "location_id"
    t.integer  "status",                               default: 0
  end

  add_index "ads", ["location_id"], name: "index_ads_on_location_id"
  add_index "ads", ["user_id"], name: "index_ads_on_user_id"

  create_table "bookings", force: :cascade do |t|
    t.integer  "ad_item_id"
    t.integer  "from_user_id"
    t.integer  "status",                                  default: 0
    t.decimal  "price",          precision: 10, scale: 2
    t.datetime "booking_from"
    t.datetime "booking_to"
    t.datetime "first_reply_at"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "bookings", ["ad_item_id"], name: "index_bookings_on_ad_item_id"
  add_index "bookings", ["from_user_id"], name: "index_bookings_on_from_user_id"
  add_index "bookings", ["status"], name: "index_bookings_on_status"

  create_table "favorite_ads", force: :cascade do |t|
    t.integer  "favorite_list_id"
    t.integer  "ad_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "favorite_ads", ["ad_id"], name: "index_favorite_ads_on_ad_id"
  add_index "favorite_ads", ["favorite_list_id"], name: "index_favorite_ads_on_favorite_list_id"

  create_table "favorite_lists", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "favorite_lists", ["user_id"], name: "index_favorite_lists_on_user_id"

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "ad_id"
    t.integer  "from_user_id"
    t.integer  "score"
    t.text     "body"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "feedbacks", ["ad_id"], name: "index_feedbacks_on_ad_id"
  add_index "feedbacks", ["from_user_id"], name: "index_feedbacks_on_from_user_id"

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "image_url"
    t.string   "profile_url"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "identities", ["uid"], name: "index_identities_on_uid"
  add_index "identities", ["user_id"], name: "index_identities_on_user_id"

  create_table "locations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "address_line"
    t.string   "city"
    t.string   "state"
    t.string   "post_code"
    t.decimal  "lat",          precision: 15, scale: 13
    t.decimal  "lon",          precision: 15, scale: 13
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "locations", ["user_id"], name: "index_locations_on_user_id"

  create_table "messages", force: :cascade do |t|
    t.integer  "booking_id"
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.text     "content"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "messages", ["booking_id"], name: "index_messages_on_booking_id"
  add_index "messages", ["from_user_id"], name: "index_messages_on_from_user_id"
  add_index "messages", ["to_user_id"], name: "index_messages_on_to_user_id"

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "status",          default: 0
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.string   "message"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "notifications", ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id"

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "phone_number",                      limit: 8
    t.integer  "ephemeral_answer_percent"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "status",                                      default: 1
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                               default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                             default: 0, null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "image_url"
    t.string   "phone_number_confirmation_token"
    t.datetime "phone_number_confirmed_at"
    t.datetime "phone_number_confirmation_sent_at"
    t.string   "unconfirmed_phone_number",          limit: 8
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["status"], name: "index_users_on_status"
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true

end
