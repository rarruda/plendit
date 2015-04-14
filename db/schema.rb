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

ActiveRecord::Schema.define(version: 20150412142118) do

  create_table "ad_items", force: :cascade do |t|
    t.integer  "ad_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ad_items", ["ad_id"], name: "index_ad_items_on_ad_id"

  create_table "ads", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.string   "short_description"
    t.text     "body"
    t.decimal  "price",             precision: 10, scale: 2
    t.text     "tags"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "ads", ["user_id"], name: "index_ads_on_user_id"

  create_table "booking_statuses", force: :cascade do |t|
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bookings", force: :cascade do |t|
    t.integer  "ad_item_id"
    t.integer  "from_user_id"
    t.integer  "booking_status_id"
    t.decimal  "price",             precision: 10, scale: 2
    t.datetime "booking_from"
    t.datetime "booking_to"
    t.datetime "first_reply_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "bookings", ["ad_item_id"], name: "index_bookings_on_ad_item_id"
  add_index "bookings", ["booking_status_id"], name: "index_bookings_on_booking_status_id"
  add_index "bookings", ["from_user_id"], name: "index_bookings_on_from_user_id"

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

  create_table "user_statuses", force: :cascade do |t|
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "phone_number",             limit: 8
    t.datetime "join_timestamp"
    t.datetime "last_action_timestamp"
    t.string   "private_link_to_facebook"
    t.string   "private_link_to_linkedin"
    t.integer  "ephemeral_answer_percent"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "user_status_id"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                    default: 0, null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  add_index "users", ["user_status_id"], name: "index_users_on_user_status_id"

end
