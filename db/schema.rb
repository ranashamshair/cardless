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

ActiveRecord::Schema.define(version: 2021_07_07_114947) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_transfers", force: :cascade do |t|
    t.integer "receiver_wallet_id"
    t.integer "sender_wallet_id"
    t.float "amount"
    t.text "instruction"
    t.string "reason"
    t.float "sender_balance"
    t.float "receiver_balance"
    t.integer "sender_id"
    t.integer "receiver_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "fee", default: 0.0
    t.integer "tx_id"
    t.string "ref_id"
  end

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
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "banks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "iban"
    t.integer "status"
    t.string "currency"
    t.string "user_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "bank_name"
    t.string "country"
    t.index ["user_id"], name: "index_banks_on_user_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "first6"
    t.string "last4"
    t.string "exp_date"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "brand"
    t.string "card_type"
    t.text "fingerprint"
    t.text "distro_token"
  end

  create_table "companies", force: :cascade do |t|
    t.integer "user_id"
    t.string "address"
    t.string "country"
    t.string "city"
    t.string "postcode"
    t.string "logo"
    t.string "business_type"
    t.string "industry"
    t.string "buisness_work"
    t.string "name"
    t.string "vat"
    t.string "website"
    t.string "support_email"
    t.string "phone"
    t.string "legal_doc"
    t.string "id_doc"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "legal_doc_type"
  end

  create_table "fees", force: :cascade do |t|
    t.float "sale_credit_bank", default: 0.0
    t.float "withdraw", default: 0.0
    t.float "reserve", default: 0.0
    t.integer "days", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "sale_debit_bank", default: 0.0
    t.float "sale_credit_merchant", default: 0.0
    t.float "sale_debit_merchant", default: 0.0
    t.float "sale_credit_bank_percent", default: 0.0
    t.float "sale_debit_bank_percent", default: 0.0
    t.float "sale_credit_merchant_percent", default: 0.0
    t.float "sale_debit_merchant_percent", default: 0.0
    t.float "refund", default: 0.0
    t.float "account_transfer", default: 0.0
    t.float "reward_amount", default: 0.0
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

  create_table "payment_gateways", force: :cascade do |t|
    t.integer "gateway_type"
    t.string "name"
    t.text "client_secret"
    t.text "client_id"
    t.boolean "is_block", default: false
    t.boolean "is_deleted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "merchant_id"
    t.string "redirect_url"
    t.string "base_url"
    t.string "secret_word"
  end

  create_table "refunds", force: :cascade do |t|
    t.float "amount"
    t.string "reason"
    t.integer "transfer_id"
    t.integer "sender_id"
    t.integer "receiver_id"
    t.integer "refund_tx_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "charge_id"
  end

  create_table "reserve_schedules", force: :cascade do |t|
    t.integer "transaction_id"
    t.datetime "release_date"
    t.datetime "tx_date"
    t.float "amount"
    t.string "tx_id"
    t.string "reserve_status"
    t.integer "user_id"
    t.integer "reserve_tx_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "reward_infos", force: :cascade do |t|
    t.float "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "rewards", force: :cascade do |t|
    t.integer "user_id"
    t.float "amount", default: 0.0
    t.boolean "payed", default: false
    t.datetime "payed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.float "amount"
    t.integer "status"
    t.string "charge_id"
    t.integer "sender_id"
    t.integer "receiver_id"
    t.integer "action"
    t.float "fee"
    t.float "reserve_money"
    t.integer "main_type"
    t.string "first6"
    t.string "last4"
    t.integer "sender_wallet_id"
    t.integer "receiver_wallet_id"
    t.float "sender_balance"
    t.float "receiver_balance"
    t.string "ref_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "card_id"
    t.float "bank_fee", default: 0.0
    t.float "net_amount", default: 0.0
    t.float "total_fee", default: 0.0
    t.bigint "bank_id"
    t.integer "payment_gateway_id"
    t.integer "issue_transaction_id"
    t.integer "refund_transaction_id"
    t.index ["bank_id"], name: "index_transactions_on_bank_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "country"
    t.string "city"
    t.string "state"
    t.string "phone_number"
    t.string "company"
    t.string "role"
    t.string "is_active", default: "false"
    t.string "street_address"
    t.string "zip_code"
    t.bigint "payment_gateway_id"
    t.string "org_name"
    t.string "business_type"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "authentication_token"
    t.string "secret_key"
    t.string "public_key"
    t.string "unconfirmed_email"
    t.string "stripe_customer_id"
    t.string "brain_tree_id"
    t.string "tax_id"
    t.string "nic"
    t.string "business_license"
    t.string "business_tax_id"
    t.string "website"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["payment_gateway_id"], name: "index_users_on_payment_gateway_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.string "name"
    t.string "wallet_type"
    t.bigint "user_id", null: false
    t.float "balance", default: 0.0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.index ["slug"], name: "index_wallets_on_slug", unique: true
    t.index ["user_id"], name: "index_wallets_on_user_id"
  end

  create_table "withdraws", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.boolean "is_payed"
    t.float "amount", default: 0.0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ref_id"
    t.integer "transaction_id"
    t.datetime "payed_at"
    t.bigint "bank_id"
    t.index ["bank_id"], name: "index_withdraws_on_bank_id"
    t.index ["user_id"], name: "index_withdraws_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "banks", "users"
  add_foreign_key "transactions", "banks"
  add_foreign_key "wallets", "users"
  add_foreign_key "withdraws", "banks"
  add_foreign_key "withdraws", "users"
end
