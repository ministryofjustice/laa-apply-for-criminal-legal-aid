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

ActiveRecord::Schema[7.0].define(version: 2022_10_13_084746) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", null: false
    t.uuid "person_id", null: false
    t.string "address_line_one"
    t.string "address_line_two"
    t.string "city"
    t.string "country"
    t.string "postcode"
    t.string "lookup_id"
    t.index ["person_id"], name: "index_addresses_on_person_id"
    t.index ["type", "person_id"], name: "index_addresses_on_type_and_person_id", unique: true
  end

  create_table "cases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "urn"
    t.uuid "crime_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "case_type"
    t.string "cc_appeal_maat_id"
    t.string "cc_appeal_fin_change_maat_id"
    t.text "cc_appeal_fin_change_details"
    t.string "has_codefendants"
    t.string "hearing_court_name"
    t.date "hearing_date"
    t.index ["crime_application_id"], name: "index_cases_on_crime_application_id", unique: true
  end

  create_table "charges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "case_id", null: false
    t.string "offence_name"
    t.index ["case_id"], name: "index_charges_on_case_id"
  end

  create_table "codefendants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "case_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "conflict_of_interest"
    t.index ["case_id"], name: "index_codefendants_on_case_id"
  end

  create_table "crime_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "navigation_stack", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_has_partner"
    t.string "status"
    t.datetime "date_stamp"
  end

  create_table "offence_dates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "charge_id", null: false
    t.date "date"
    t.index ["charge_id"], name: "index_offence_dates_on_charge_id"
  end

  create_table "people", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", null: false
    t.uuid "crime_application_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "other_names"
    t.date "date_of_birth"
    t.string "has_nino"
    t.string "nino"
    t.string "telephone_number"
    t.string "correspondence_address_type"
    t.boolean "passporting_benefit"
    t.index ["crime_application_id"], name: "index_people_on_crime_application_id", unique: true
  end

  add_foreign_key "addresses", "people"
  add_foreign_key "cases", "crime_applications"
  add_foreign_key "charges", "cases"
  add_foreign_key "codefendants", "cases"
  add_foreign_key "offence_dates", "charges"
  add_foreign_key "people", "crime_applications"
end
