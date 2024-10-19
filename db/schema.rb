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

ActiveRecord::Schema[7.2].define(version: 2024_10_18_213708) do
  create_table "cve_nist_mappings", force: :cascade do |t|
    t.string "cve_id"
    t.text "nist_control_identifiers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cve_id"], name: "index_cve_nist_mappings_on_cve_id", unique: true
  end

  create_table "images", force: :cascade do |t|
    t.string "tag"
    t.text "report"
    t.integer "run_time_object_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_time_object_id"], name: "index_images_on_run_time_object_id"
  end

  create_table "run_time_objects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_run_time_objects_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "uid"
    t.string "provider"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "images", "run_time_objects"
  add_foreign_key "run_time_objects", "users"
end
