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

ActiveRecord::Schema[7.0].define(version: 2024_11_19_113021) do
  create_table "deposits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.decimal "amount", precision: 12, scale: 2
    t.string "platform"
    t.string "order_no"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform", "order_no"], name: "index_deposits_on_platform_and_order_no", unique: true
    t.index ["user_id"], name: "index_deposits_on_user_id"
  end

  create_table "events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "eventable_type"
    t.bigint "eventable_id"
    t.string "event_type"
    t.integer "related_event_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_events_on_event_type"
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable"
    t.index ["related_event_id"], name: "index_events_on_related_event_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "transfers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "from_user_id"
    t.integer "to_user_id"
    t.decimal "amount", precision: 10, scale: 2
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_user_id"], name: "index_transfers_on_from_user_id"
    t.index ["to_user_id"], name: "index_transfers_on_to_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wallets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.decimal "balance", precision: 12, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id", unique: true
  end

  create_table "withdrawals", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.decimal "amount", precision: 12, scale: 2
    t.string "platform"
    t.string "order_no"
    t.string "status"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform", "order_no"], name: "index_withdrawals_on_platform_and_order_no", unique: true
    t.index ["user_id"], name: "index_withdrawals_on_user_id"
  end

end
