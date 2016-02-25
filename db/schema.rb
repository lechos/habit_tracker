ActiveRecord::Schema.define(version: 20160225074715) do

  create_table "days", force: :cascade do |t|
    t.integer  "habit_id"
    t.integer  "position"
    t.string   "result",     default: "0"
    t.string   "message"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "habits", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "start_date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.string   "description"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "password"
  end

end
