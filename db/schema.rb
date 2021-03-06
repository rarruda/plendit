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

ActiveRecord::Schema.define(version: 20160522145918) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accident_report_attachments", force: :cascade do |t|
    t.integer  "accident_report_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "accident_report_attachments", ["accident_report_id"], name: "index_accident_report_attachments_on_accident_report_id", using: :btree

  create_table "accident_reports", force: :cascade do |t|
    t.integer  "booking_id"
    t.integer  "from_user_id"
    t.datetime "happened_at"
    t.string   "location_line"
    t.text     "body"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

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

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

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

  add_index "ad_images", ["ad_id"], name: "index_ad_images_on_ad_id", using: :btree

  create_table "ad_items", force: :cascade do |t|
    t.integer  "ad_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ad_items", ["ad_id"], name: "index_ad_items_on_ad_id", using: :btree

  create_table "ads", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.text     "tags"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "location_id"
    t.integer  "status",                        default: 0
    t.integer  "category",                      default: 0
    t.string   "registration_number"
    t.integer  "registration_group"
    t.integer  "estimated_value"
    t.boolean  "boat_license_required"
    t.string   "refusal_reason"
    t.boolean  "accepted_boat_insurance_terms", default: false
  end

  add_index "ads", ["location_id"], name: "index_ads_on_location_id", using: :btree
  add_index "ads", ["user_id"], name: "index_ads_on_user_id", using: :btree

  create_table "bookings", force: :cascade do |t|
    t.integer  "ad_item_id"
    t.integer  "from_user_id"
    t.integer  "status",               default: 0
    t.integer  "payout_amount"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "first_reply_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "guid"
    t.integer  "platform_fee_amount",  default: 0
    t.integer  "insurance_amount",     default: 0
    t.integer  "user_payment_card_id"
    t.integer  "deposit_amount",       default: 0
    t.integer  "deposit_offer_amount", default: 0
  end

  add_index "bookings", ["ad_item_id"], name: "index_bookings_on_ad_item_id", using: :btree
  add_index "bookings", ["from_user_id"], name: "index_bookings_on_from_user_id", using: :btree
  add_index "bookings", ["guid"], name: "index_bookings_on_guid", unique: true, using: :btree
  add_index "bookings", ["status"], name: "index_bookings_on_status", using: :btree
  add_index "bookings", ["user_payment_card_id"], name: "index_bookings_on_user_payment_card_id", using: :btree

  create_table "favorite_ads", force: :cascade do |t|
    t.integer  "favorite_list_id"
    t.integer  "ad_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "favorite_ads", ["ad_id"], name: "index_favorite_ads_on_ad_id", using: :btree
  add_index "favorite_ads", ["favorite_list_id"], name: "index_favorite_ads_on_favorite_list_id", using: :btree

  create_table "favorite_lists", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "favorite_lists", ["user_id"], name: "index_favorite_lists_on_user_id", using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "from_user_id"
    t.integer  "score"
    t.text     "body"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "booking_id"
    t.integer  "to_user_id"
  end

  add_index "feedbacks", ["booking_id"], name: "index_feedbacks_on_booking_id", using: :btree
  add_index "feedbacks", ["from_user_id"], name: "index_feedbacks_on_from_user_id", using: :btree
  add_index "feedbacks", ["to_user_id"], name: "index_feedbacks_on_to_user_id", using: :btree

  create_table "financial_transactions", force: :cascade do |t|
    t.string   "guid",                           limit: 36
    t.string   "src_vid"
    t.integer  "src_type"
    t.string   "dst_vid"
    t.integer  "dst_type"
    t.string   "transaction_vid"
    t.integer  "transaction_type"
    t.integer  "state"
    t.integer  "amount"
    t.integer  "fees"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.string   "result_code"
    t.string   "result_message"
    t.text     "response_body"
    t.integer  "nature",                                    default: 0
    t.integer  "financial_transactionable_id"
    t.string   "financial_transactionable_type"
    t.integer  "preauth_payment_status",                    default: 0
    t.integer  "purpose"
  end

  add_index "financial_transactions", ["dst_vid"], name: "index_financial_transactions_on_dst_vid", using: :btree
  add_index "financial_transactions", ["financial_transactionable_type", "financial_transactionable_id"], name: "index_transactions_on_transactionable_type_and_id", using: :btree
  add_index "financial_transactions", ["guid"], name: "index_financial_transactions_on_guid", using: :btree
  add_index "financial_transactions", ["src_vid"], name: "index_financial_transactions_on_src_vid", using: :btree
  add_index "financial_transactions", ["transaction_vid"], name: "index_financial_transactions_on_transaction_vid", using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "image_url"
    t.string   "profile_url"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "email"
    t.string   "name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "nickname"
    t.integer  "verification_level"
  end

  add_index "identities", ["uid"], name: "index_identities_on_uid", using: :btree
  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "address_line"
    t.string   "city"
    t.string   "state"
    t.string   "post_code"
    t.decimal  "lat",                           precision: 15, scale: 13
    t.decimal  "lon",                           precision: 15, scale: 13
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.integer  "status",                                                  default: 0
    t.boolean  "favorite",                                                default: false
    t.integer  "geo_precision"
    t.string   "geo_precision_type"
    t.string   "guid",               limit: 36
  end

  add_index "locations", ["guid"], name: "index_locations_on_guid", unique: true, using: :btree
  add_index "locations", ["user_id"], name: "index_locations_on_user_id", using: :btree

  create_table "mangopay_webhooks", force: :cascade do |t|
    t.string   "event_type"
    t.string   "resource_vid"
    t.string   "timestamp_v"
    t.integer  "status",        default: 0
    t.string   "remote_ip"
    t.text     "raw_data"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "resource_type"
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "booking_id"
    t.integer  "from_user_id"
    t.integer  "to_user_id"
    t.text     "content"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "messages", ["booking_id"], name: "index_messages_on_booking_id", using: :btree
  add_index "messages", ["from_user_id"], name: "index_messages_on_from_user_id", using: :btree
  add_index "messages", ["to_user_id"], name: "index_messages_on_to_user_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "status",            default: 0
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.string   "message"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "is_system_message", default: false
  end

  add_index "notifications", ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "payin_rules", force: :cascade do |t|
    t.integer  "unit"
    t.integer  "payin_amount"
    t.integer  "effective_from"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "ad_id"
    t.string   "guid",           limit: 36
  end

  add_index "payin_rules", ["ad_id"], name: "index_payin_rules_on_ad_id", using: :btree
  add_index "payin_rules", ["guid"], name: "index_payin_rules_on_guid", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "unavailabilities", force: :cascade do |t|
    t.date     "starts_at"
    t.date     "ends_at"
    t.integer  "ad_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "unavailabilities", ["ad_id"], name: "index_unavailabilities_on_ad_id", using: :btree

  create_table "user_documents", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "guid",                  limit: 36
    t.integer  "category"
    t.integer  "status"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.date     "expires_at"
    t.string   "rejection_reason"
  end

  add_index "user_documents", ["guid"], name: "index_user_documents_on_guid", using: :btree
  add_index "user_documents", ["user_id"], name: "index_user_documents_on_user_id", using: :btree

  create_table "user_images", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "category"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "user_payment_accounts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "bank_account_number"
    t.string   "bank_account_iban"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "bank_account_vid"
  end

  add_index "user_payment_accounts", ["user_id"], name: "index_user_payment_accounts_on_user_id", using: :btree

  create_table "user_payment_cards", force: :cascade do |t|
    t.string   "guid",            limit: 36
    t.integer  "user_id"
    t.string   "card_vid"
    t.string   "currency",        limit: 3
    t.string   "card_type"
    t.string   "number_alias",    limit: 16
    t.string   "expiration_date", limit: 4
    t.integer  "validity"
    t.boolean  "active",                     default: true,  null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "card_provider"
    t.string   "country",         limit: 3
    t.boolean  "favorite",                   default: false
  end

  add_index "user_payment_cards", ["card_vid"], name: "index_user_payment_cards_on_card_vid", using: :btree
  add_index "user_payment_cards", ["guid"], name: "index_user_payment_cards_on_guid", using: :btree
  add_index "user_payment_cards", ["user_id"], name: "index_user_payment_cards_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "phone_number",                      limit: 8
    t.integer  "ephemeral_answer_percent"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.integer  "status",                                      default: 1
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                               default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                             default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "image_url"
    t.string   "phone_number_confirmation_token"
    t.datetime "phone_number_confirmed_at"
    t.datetime "phone_number_confirmation_sent_at"
    t.string   "unconfirmed_phone_number",          limit: 8
    t.string   "first_name"
    t.date     "birthday"
    t.string   "last_name"
    t.integer  "personhood"
    t.boolean  "pays_vat"
    t.string   "payment_provider_vid"
    t.string   "nationality",                       limit: 2
    t.string   "country_of_residence",              limit: 2
    t.string   "home_address_line"
    t.string   "home_post_code"
    t.string   "home_city"
    t.string   "home_state"
    t.string   "payin_wallet_vid"
    t.string   "payout_wallet_vid"
    t.text     "about"
    t.float    "feedback_score",                              default: 0.0
    t.integer  "feedback_score_count",                        default: 0
    t.datetime "feedback_score_updated_at"
    t.boolean  "seamanship_claimed",                          default: false
    t.string   "personal_id_number"
    t.integer  "verification_level",                          default: 0
    t.string   "public_name"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["personal_id_number"], name: "index_users_on_personal_id_number", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["status"], name: "index_users_on_status", using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "wanted_item_requests", force: :cascade do |t|
    t.string   "description"
    t.text     "email"
    t.integer  "user_id"
    t.string   "place"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "when"
  end

  add_index "wanted_item_requests", ["user_id"], name: "index_wanted_item_requests_on_user_id", using: :btree

  add_foreign_key "accident_report_attachments", "accident_reports"
  add_foreign_key "ad_images", "ads"
  add_foreign_key "ad_items", "ads"
  add_foreign_key "ads", "locations"
  add_foreign_key "ads", "users"
  add_foreign_key "bookings", "ad_items"
  add_foreign_key "bookings", "user_payment_cards"
  add_foreign_key "bookings", "users", column: "from_user_id"
  add_foreign_key "favorite_ads", "ads"
  add_foreign_key "favorite_ads", "favorite_lists"
  add_foreign_key "favorite_lists", "users"
  add_foreign_key "feedbacks", "bookings"
  add_foreign_key "feedbacks", "users", column: "from_user_id"
  add_foreign_key "feedbacks", "users", column: "to_user_id"
  add_foreign_key "identities", "users"
  add_foreign_key "locations", "users"
  add_foreign_key "messages", "bookings"
  add_foreign_key "messages", "users", column: "from_user_id"
  add_foreign_key "messages", "users", column: "to_user_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "payin_rules", "ads"
  add_foreign_key "unavailabilities", "ads"
  add_foreign_key "user_documents", "users"
  add_foreign_key "user_payment_accounts", "users"
  add_foreign_key "user_payment_cards", "users"
  add_foreign_key "wanted_item_requests", "users"
end
