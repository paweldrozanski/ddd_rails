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

ActiveRecord::Schema.define(version: 2024_04_04_123529) do

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "discount_sagas", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.string "state", null: false
    t.binary "data"
    t.index ["customer_id"], name: "index_active_discount_sagas_on_customer_id", unique: true, where: "state = 'active'"
    t.index ["customer_id"], name: "index_discount_sagas_on_customer_id"
  end

  create_table "event_store_events", id: :string, limit: 36, force: :cascade do |t|
    t.string "event_type", null: false
    t.binary "metadata"
    t.binary "data", null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_event_store_events_on_created_at"
    t.index ["event_type"], name: "index_event_store_events_on_event_type"
  end

  create_table "event_store_events_in_streams", force: :cascade do |t|
    t.string "stream", null: false
    t.integer "position"
    t.string "event_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_event_store_events_in_streams_on_created_at"
    t.index ["stream", "event_id"], name: "index_event_store_events_in_streams_on_stream_and_event_id", unique: true
    t.index ["stream", "position"], name: "index_event_store_events_in_streams_on_stream_and_position", unique: true
  end

  create_table "inventory_products", force: :cascade do |t|
    t.integer "store_id", null: false
    t.string "sku", null: false
    t.integer "quantity_available", null: false
    t.integer "quantity_shipped", null: false
    t.integer "quantity_reserved", null: false
  end

  create_table "inventory_shipments", force: :cascade do |t|
    t.integer "store_id", null: false
    t.string "state", null: false
    t.string "order_number", null: false
    t.text "data"
  end

  create_table "inventory_stores", force: :cascade do |t|
    t.string "name"
    t.text "data"
  end

  create_table "orders", force: :cascade do |t|
    t.string "number"
    t.integer "items_count"
    t.decimal "net_value"
    t.decimal "vat_amount"
    t.decimal "gross_value"
    t.string "customer_name"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_orders_on_number", unique: true
  end

  create_table "payment_gateway_transactions", force: :cascade do |t|
    t.string "identifier", null: false
    t.decimal "amount", null: false
    t.string "card_number", null: false
    t.string "state", null: false
    t.index ["identifier"], name: "index_payment_gateway_transactions_on_identifier"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.decimal "net_price"
    t.integer "vat_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
