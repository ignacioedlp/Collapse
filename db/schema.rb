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

ActiveRecord::Schema[7.2].define(version: 2025_09_13_150521) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_admin_users_on_active"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "ban_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "admin_user_id", null: false
    t.string "action", null: false
    t.text "reason"
    t.datetime "banned_until"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action"], name: "index_ban_logs_on_action"
    t.index ["admin_user_id"], name: "index_ban_logs_on_admin_user_id"
    t.index ["created_at"], name: "index_ban_logs_on_created_at"
    t.index ["user_id", "created_at"], name: "index_ban_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_ban_logs_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "reported_user_id", null: false
    t.bigint "reporter_id", null: false
    t.string "reason", null: false
    t.text "description", null: false
    t.string "status", default: "pending"
    t.string "ip_address"
    t.bigint "reviewed_by_id"
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_reports_on_created_at"
    t.index ["reason"], name: "index_reports_on_reason"
    t.index ["reported_user_id", "created_at"], name: "index_reports_on_reported_user_id_and_created_at"
    t.index ["reported_user_id"], name: "index_reports_on_reported_user_id"
    t.index ["reporter_id"], name: "index_reports_on_reporter_id"
    t.index ["reviewed_by_id"], name: "index_reports_on_reviewed_by_id"
    t.index ["status"], name: "index_reports_on_status"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.string "google_id"
    t.string "provider"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar"
    t.datetime "banned_at"
    t.text "banned_reason"
    t.datetime "banned_until"
    t.bigint "banned_by_id"
    t.index ["banned_at"], name: "index_users_on_banned_at"
    t.index ["banned_by_id"], name: "index_users_on_banned_by_id"
    t.index ["banned_until"], name: "index_users_on_banned_until"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_id"], name: "index_users_on_google_id"
    t.index ["provider"], name: "index_users_on_provider"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "ban_logs", "admin_users"
  add_foreign_key "ban_logs", "users"
  add_foreign_key "reports", "admin_users", column: "reviewed_by_id"
  add_foreign_key "reports", "users", column: "reported_user_id"
  add_foreign_key "reports", "users", column: "reporter_id"
  add_foreign_key "users", "admin_users", column: "banned_by_id"
  add_foreign_key "users_roles", "roles"
  add_foreign_key "users_roles", "users"
end
