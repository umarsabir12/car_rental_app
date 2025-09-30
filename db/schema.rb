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

ActiveRecord::Schema[7.2].define(version: 2025_09_30_174636) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.string "role_type", default: "admin"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["role_type"], name: "index_admins_on_role_type"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "car_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "payment_processed"
    t.string "stripe_session_id"
    t.string "stripe_payment_intent_id"
    t.integer "payment_mode", default: 1, null: false
    t.string "selected_period"
    t.decimal "selected_price", precision: 10, scale: 2
    t.integer "selected_mileage_limit"
    t.index ["car_id"], name: "index_bookings_on_car_id"
    t.index ["payment_mode"], name: "index_bookings_on_payment_mode"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "car_documents", force: :cascade do |t|
    t.bigint "car_id", null: false
    t.integer "document_status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_id"], name: "index_car_documents_on_car_id"
  end

  create_table "cars", force: :cascade do |t|
    t.string "model"
    t.string "brand"
    t.string "category"
    t.string "color"
    t.integer "year"
    t.integer "daily_price"
    t.string "status"
    t.text "description"
    t.string "main_image_url"
    t.string "transmission"
    t.string "fuel_type"
    t.integer "seats"
    t.integer "mileage"
    t.string "engine_size"
    t.boolean "air_conditioning", default: true
    t.boolean "gps", default: false
    t.boolean "sunroof", default: false
    t.boolean "bluetooth", default: false
    t.boolean "featured", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_id"
    t.string "stripe_product_id"
    t.string "stripe_price_id"
    t.boolean "with_driver", default: false
    t.integer "weekly_price"
    t.integer "monthly_price"
    t.integer "daily_milleage", default: 0
    t.integer "weekly_milleage", default: 0
    t.integer "monthly_milleage", default: 0
    t.string "insurance_policy_number", default: ""
    t.string "insurance_policy", default: ""
    t.integer "additional_mileage_charge", default: 0
    t.integer "bookings_count", default: 0, null: false
    t.index ["stripe_price_id"], name: "index_cars_on_stripe_price_id"
    t.index ["stripe_product_id"], name: "index_cars_on_stripe_product_id"
    t.index ["vendor_id"], name: "index_cars_on_vendor_id"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "doc_name"
    t.string "document_type"
    t.string "status", default: "not uploaded"
    t.string "reason", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "invited_vendors", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "invite_token"
    t.boolean "invite_sent", default: false
    t.string "status", default: "pending"
    t.datetime "expires_at", default: "2025-09-25 09:01:03"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.string "stripe_payment_intent_id"
    t.string "stripe_session_id"
    t.decimal "amount"
    t.string "status"
    t.string "transaction_type"
    t.decimal "refund_amount"
    t.text "refund_reason"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_transactions_on_booking_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "home_address"
    t.boolean "terms_accepted"
    t.string "card_number"
    t.string "card_expiry"
    t.string "card_cvc"
    t.boolean "payment_done"
    t.string "nationality"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vendor_documents", force: :cascade do |t|
    t.bigint "vendor_id", null: false
    t.integer "document_status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vendor_id"], name: "index_vendor_documents_on_vendor_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "phone"
    t.string "company_name"
    t.string "company_logo"
    t.string "address"
    t.string "website"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "emirates_id"
    t.date "emirates_id_expires_on"
    t.index ["email"], name: "index_vendors_on_email", unique: true
    t.index ["emirates_id"], name: "index_vendors_on_emirates_id", unique: true, where: "(emirates_id IS NOT NULL)"
    t.index ["reset_password_token"], name: "index_vendors_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookings", "cars"
  add_foreign_key "bookings", "users"
  add_foreign_key "car_documents", "cars"
  add_foreign_key "cars", "vendors"
  add_foreign_key "documents", "users"
  add_foreign_key "transactions", "bookings"
  add_foreign_key "vendor_documents", "vendors"
end
