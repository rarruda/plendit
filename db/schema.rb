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

ActiveRecord::Schema.define(version: 20150331180901) do

  create_table "ad_items", force: :cascade do |t|
    t.integer  "ad_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ad_items", ["ad_id"], name: "index_ad_items_on_ad_id"

  create_table "ads", force: :cascade do |t|
    t.integer  "profile_id"
    t.string   "title"
    t.string   "short_description"
    t.text     "body"
    t.decimal  "price",             precision: 10, scale: 2
    t.text     "tags"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "ads", ["profile_id"], name: "index_ads_on_profile_id"

  create_table "booking_statuses", force: :cascade do |t|
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bookings", force: :cascade do |t|
    t.integer  "ad_item_id"
    t.integer  "from_profile_id"
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
  add_index "bookings", ["from_profile_id"], name: "index_bookings_on_from_profile_id"

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "ad_id"
    t.integer  "from_profile_id"
    t.integer  "score"
    t.text     "body"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "feedbacks", ["ad_id"], name: "index_feedbacks_on_ad_id"
  add_index "feedbacks", ["from_profile_id"], name: "index_feedbacks_on_from_profile_id"

  create_table "messages", force: :cascade do |t|
    t.integer  "booking_id"
    t.integer  "from_profile_id"
    t.integer  "to_profile_id"
    t.text     "content"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "messages", ["booking_id"], name: "index_messages_on_booking_id"
  add_index "messages", ["from_profile_id"], name: "index_messages_on_from_profile_id"
  add_index "messages", ["to_profile_id"], name: "index_messages_on_to_profile_id"

  create_table "profile_statuses", force: :cascade do |t|
    t.string   "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string   "name"
    t.string   "phone_number",             limit: 8
    t.datetime "join_timestamp"
    t.datetime "last_action_timestamp"
    t.string   "private_link_to_facebook"
    t.string   "private_link_to_linkedin"
    t.integer  "ephemeral_answer_percent"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "profile_status_id"
  end

  add_index "profiles", ["profile_status_id"], name: "index_profiles_on_profile_status_id"

end
