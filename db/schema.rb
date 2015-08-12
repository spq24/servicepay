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

ActiveRecord::Schema.define(version: 20150812121954) do

  create_table "active_admin_comments", force: true do |t|
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

  create_table "admin_users", force: true do |t|
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

  create_table "companies", force: true do |t|
    t.string   "company_name"
    t.string   "address_one"
    t.string   "address_two"
    t.string   "city"
    t.string   "state"
    t.string   "postcode"
    t.string   "country"
    t.string   "phonenumber"
    t.string   "website_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.string   "provider"
    t.string   "facebook"
    t.string   "google"
    t.string   "yelp"
    t.datetime "deleted_at"
    t.string   "encrypted_publishable_key"
    t.string   "encrypted_uid"
    t.string   "encrypted_access_code"
    t.boolean  "status"
    t.boolean  "terms"
    t.text     "description"
    t.float    "application_fee",               default: 0.8
    t.string   "encrypted_quickbooks_token"
    t.string   "encrypted_quickbooks_secret"
    t.string   "encrypted_quickbooks_realm_id"
    t.datetime "quickbooks_token_expires_at",   default: '2016-01-17 00:06:33'
    t.datetime "quickbooks_reconnect_token_at", default: '2015-12-17 00:06:33'
    t.text     "default_invoice_terms"
  end

  add_index "companies", ["deleted_at"], name: "index_companies_on_deleted_at"

  create_table "coupons", force: true do |t|
    t.string   "name"
    t.string   "duration"
    t.integer  "amount_off"
    t.integer  "currency"
    t.integer  "duration_in_months"
    t.integer  "max_redemptions"
    t.integer  "percent_off"
    t.datetime "redeem_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "user_id"
    t.boolean  "active",             default: true
    t.integer  "redeemed_count",     default: 0
  end

  create_table "customers", force: true do |t|
    t.integer  "company_id"
    t.string   "customer_email"
    t.string   "customer_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "encrypted_stripe_token"
    t.integer  "coupon_id"
    t.string   "address_one"
    t.string   "address_two"
    t.string   "city"
    t.string   "state"
    t.string   "country",                default: "usa"
    t.string   "postcode"
    t.string   "phone"
    t.integer  "quickbooks_customer_id"
    t.string   "unique_name"
  end

  add_index "customers", ["deleted_at"], name: "index_customers_on_deleted_at"

  create_table "invoice_items", force: true do |t|
    t.integer  "unit_cost"
    t.integer  "quantity"
    t.integer  "price"
    t.integer  "invoice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  create_table "invoices", force: true do |t|
    t.integer  "customer_id"
    t.integer  "user_id"
    t.integer  "company_id"
    t.string   "invoice_number",      default: "00000001"
    t.datetime "issue_date"
    t.text     "private_notes"
    t.text     "customer_notes"
    t.text     "payment_terms"
    t.boolean  "draft"
    t.string   "status"
    t.float    "discount"
    t.string   "po_number"
    t.boolean  "recurring"
    t.string   "interval"
    t.datetime "recurring_send_date"
    t.boolean  "auto_paid"
    t.string   "contact_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "send_by_post"
    t.boolean  "send_by_email"
    t.integer  "total"
  end

  create_table "items", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "unit_cost"
  end

  create_table "payments", force: true do |t|
    t.integer  "company_id"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_charge_id"
    t.boolean  "refunded"
    t.string   "stripe_refund_id"
    t.string   "invoice_number"
    t.integer  "customer_id"
    t.datetime "deleted_at"
    t.string   "last_4"
    t.integer  "plan_id"
    t.boolean  "subscription"
    t.integer  "coupon_id"
    t.integer  "quickbooks_customer_id"
    t.float    "app_fee"
    t.integer  "quickbooks_invoice_id"
    t.integer  "invoice_id"
  end

  add_index "payments", ["deleted_at"], name: "index_payments_on_deleted_at"

  create_table "plans", force: true do |t|
    t.string   "name"
    t.integer  "customer_id"
    t.integer  "amount"
    t.string   "currency"
    t.string   "interval"
    t.integer  "interval_count"
    t.string   "statement_descriptor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.boolean  "subscription_cancel"
  end

  create_table "refunds", force: true do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.integer  "amount"
    t.string   "stripe_refund_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_id"
    t.string   "reason"
    t.integer  "customer_id"
    t.datetime "deleted_at"
    t.integer  "quickbooks_refund_id"
  end

  add_index "refunds", ["deleted_at"], name: "index_refunds_on_deleted_at"

  create_table "reviews", force: true do |t|
    t.integer  "company_id"
    t.integer  "customer_id"
    t.string   "score"
    t.text     "comments"
    t.boolean  "google"
    t.boolean  "yelp"
    t.boolean  "facebook"
    t.boolean  "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "payment_id"
  end

  add_index "reviews", ["deleted_at"], name: "index_reviews_on_deleted_at"

  create_table "subscriptions", force: true do |t|
    t.integer  "customer_id"
    t.integer  "plan_id"
    t.string   "stripe_subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["customer_id"], name: "index_subscriptions_on_customer_id"
  add_index "subscriptions", ["plan_id"], name: "index_subscriptions_on_plan_id"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "publishable_key"
    t.string   "provider"
    t.string   "uid"
    t.string   "access_code"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.datetime "deleted_at"
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count"
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
