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

ActiveRecord::Schema.define(version: 2020_10_25_060546) do

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "birth_date"
    t.string "gender"
    t.string "nationality"
    t.string "id_number"
    t.string "id_card_image"
    t.string "city"
    t.string "country"
    t.string "floor"
    t.string "postal_code"
    t.string "street_address"
    t.string "street_number"
    t.string "proof_of_address"
    t.string "issue_id"
    t.string "issue_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
