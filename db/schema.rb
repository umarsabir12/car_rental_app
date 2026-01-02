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

ActiveRecord::Schema[7.2].define(version: 2026_01_02_114701) do
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

  create_table "activities", force: :cascade do |t|
    t.bigint "user_id"
    t.string "subject_type", null: false
    t.bigint "subject_id", null: false
    t.string "action", null: false
    t.text "description"
    t.text "metadata"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_id"
    t.index ["action"], name: "index_activities_on_action"
    t.index ["created_at"], name: "index_activities_on_created_at"
    t.index ["subject_type", "subject_id"], name: "index_activities_on_subject"
    t.index ["subject_type", "subject_id"], name: "index_activities_on_subject_type_and_subject_id"
    t.index ["user_id", "created_at"], name: "index_activities_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_activities_on_user_id"
    t.index ["vendor_id"], name: "index_activities_on_vendor_id"
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

  create_table "blogs", force: :cascade do |t|
    t.string "author_name"
    t.string "title"
    t.string "slug"
    t.string "content"
    t.string "category"
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "meta_title"
    t.string "meta_description"
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
    t.bigint "vendor_id"
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.string "delivery_option"
    t.string "payment_status", default: "pending"
    t.decimal "discount_percentage"
    t.index ["car_id", "created_at"], name: "index_bookings_on_car_id_and_created_at"
    t.index ["car_id"], name: "index_bookings_on_car_id"
    t.index ["created_at"], name: "index_bookings_on_created_at"
    t.index ["payment_mode"], name: "index_bookings_on_payment_mode"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["user_id"], name: "index_bookings_on_user_id"
    t.index ["vendor_id", "created_at"], name: "index_bookings_on_vendor_id_and_created_at"
    t.index ["vendor_id"], name: "index_bookings_on_vendor_id"
  end

  create_table "car_documents", force: :cascade do |t|
    t.bigint "car_id", null: false
    t.integer "document_status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_id"], name: "index_car_documents_on_car_id"
  end

  create_table "car_features", force: :cascade do |t|
    t.bigint "car_id", null: false
    t.bigint "feature_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_id", "feature_id"], name: "index_car_features_on_car_id_and_feature_id", unique: true
    t.index ["car_id"], name: "index_car_features_on_car_id"
    t.index ["feature_id"], name: "index_car_features_on_feature_id"
  end

  create_table "cars", force: :cascade do |t|
    t.string "model"
    t.string "brand"
    t.string "category"
    t.string "color"
    t.integer "year"
    t.integer "daily_price"
    t.string "status"
    t.string "main_image_url"
    t.string "transmission"
    t.string "fuel_type"
    t.integer "seats"
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
    t.integer "weekly_price"
    t.integer "monthly_price"
    t.integer "daily_milleage", default: 0
    t.integer "weekly_milleage", default: 0
    t.integer "monthly_milleage", default: 0
    t.string "insurance_policy", default: ""
    t.integer "additional_mileage_charge", default: 0
    t.integer "bookings_count", default: 0, null: false
    t.string "slug"
    t.boolean "with_driver"
    t.index ["brand"], name: "index_cars_on_brand"
    t.index ["category"], name: "index_cars_on_category"
    t.index ["created_at"], name: "index_cars_on_created_at"
    t.index ["featured"], name: "index_cars_on_featured"
    t.index ["slug"], name: "index_cars_on_slug", unique: true
    t.index ["status", "featured"], name: "index_cars_on_status_and_featured"
    t.index ["status"], name: "index_cars_on_status"
    t.index ["stripe_price_id"], name: "index_cars_on_stripe_price_id"
    t.index ["stripe_product_id"], name: "index_cars_on_stripe_product_id"
    t.index ["vendor_id"], name: "index_cars_on_vendor_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.bigint "vendor_id"
    t.text "category", default: [], array: true
    t.decimal "discount_percentage"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vendor_id"], name: "index_discounts_on_vendor_id"
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

  create_table "features", force: :cascade do |t|
    t.string "name"
    t.boolean "common", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_features_on_name"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "invited_vendors", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "invite_token"
    t.boolean "invite_sent", default: false
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoice_items", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.string "description", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "vendor_id", null: false
    t.string "payment_status", default: "pending"
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_payment_intent_id"
    t.datetime "paid_at"
    t.string "payment_method_id"
    t.boolean "save_payment_method", default: false
    t.string "payment_mode", default: "Online"
    t.index ["created_at"], name: "index_invoices_on_created_at"
    t.index ["payment_status"], name: "index_invoices_on_payment_status"
    t.index ["stripe_payment_intent_id"], name: "index_invoices_on_stripe_payment_intent_id", unique: true
    t.index ["vendor_id", "payment_status"], name: "index_invoices_on_vendor_id_and_payment_status"
    t.index ["vendor_id"], name: "index_invoices_on_vendor_id"
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
    t.string "whatsapp_number", limit: 20
    t.string "whatsapp_country_code", limit: 3
    t.string "provider"
    t.string "uid"
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["whatsapp_country_code"], name: "index_users_on_whatsapp_country_code"
    t.index ["whatsapp_number"], name: "index_users_on_whatsapp_number"
  end

  create_table "vendor_documents", force: :cascade do |t|
    t.bigint "vendor_id", null: false
    t.integer "document_status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vendor_id"], name: "index_vendor_documents_on_vendor_id"
  end

  create_table "vendor_requests", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.integer "vehicle_count"
    t.string "company_name"
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
    t.datetime "deleted_at"
    t.integer "payment_mode", default: 1
    t.boolean "terms_accepted", default: false
    t.string "whatsapp_number", limit: 20
    t.string "whatsapp_country_code", limit: 3
    t.string "provider"
    t.string "uid"
    t.boolean "is_active", default: true
    t.index ["created_at"], name: "index_vendors_on_created_at"
    t.index ["email"], name: "index_vendors_on_email", unique: true
    t.index ["emirates_id"], name: "index_vendors_on_emirates_id", unique: true, where: "(emirates_id IS NOT NULL)"
    t.index ["is_active"], name: "index_vendors_on_is_active"
    t.index ["reset_password_token"], name: "index_vendors_on_reset_password_token", unique: true
    t.index ["whatsapp_country_code"], name: "index_vendors_on_whatsapp_country_code"
    t.index ["whatsapp_number"], name: "index_vendors_on_whatsapp_number"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "users"
  add_foreign_key "activities", "vendors"
  add_foreign_key "bookings", "cars"
  add_foreign_key "bookings", "users"
  add_foreign_key "bookings", "vendors"
  add_foreign_key "car_documents", "cars"
  add_foreign_key "car_features", "cars"
  add_foreign_key "car_features", "features"
  add_foreign_key "cars", "vendors"
  add_foreign_key "discounts", "vendors"
  add_foreign_key "documents", "users"
  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoices", "vendors"
  add_foreign_key "transactions", "bookings"
  add_foreign_key "vendor_documents", "vendors"
end
