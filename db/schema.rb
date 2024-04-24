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

ActiveRecord::Schema[7.0].define(version: 2024_04_24_103714) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "virus_scan_status", ["awaiting", "pass", "flagged", "incomplete", "other"]

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

  create_table "capitals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "crime_application_id", null: false
    t.string "has_premium_bonds"
    t.bigint "premium_bonds_total_value"
    t.string "premium_bonds_holder_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "has_national_savings_certificates"
    t.string "will_benefit_from_trust_fund"
    t.bigint "trust_fund_amount_held"
    t.bigint "trust_fund_yearly_dividend"
    t.string "has_frozen_income_or_assets"
    t.string "has_no_other_assets"
    t.string "has_no_properties"
    t.string "has_no_savings"
    t.string "has_no_investments"
    t.index ["crime_application_id"], name: "index_capitals_on_crime_application_id", unique: true
  end

  create_table "cases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "urn"
    t.uuid "crime_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "case_type"
    t.string "appeal_maat_id"
    t.date "appeal_lodged_date"
    t.text "appeal_with_changes_details"
    t.string "has_codefendants"
    t.string "hearing_court_name"
    t.date "hearing_date"
    t.string "is_first_court_hearing"
    t.string "first_court_hearing_name"
    t.string "has_case_concluded"
    t.date "date_case_concluded"
    t.string "is_client_remanded"
    t.date "date_client_remanded"
    t.string "is_preorder_work_claimed"
    t.date "preorder_work_date"
    t.text "preorder_work_details"
    t.string "appeal_original_app_submitted"
    t.string "appeal_financial_circumstances_changed"
    t.string "appeal_reference_number"
    t.string "appeal_usn"
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
    t.string "status", default: "in_progress"
    t.datetime "date_stamp"
    t.datetime "submitted_at"
    t.serial "usn", null: false
    t.string "ioj_passport", default: [], null: false, array: true
    t.string "office_code"
    t.jsonb "provider_details", default: {}, null: false
    t.uuid "parent_id"
    t.string "means_passport", default: [], array: true
    t.string "is_means_tested"
    t.string "application_type", default: "initial", null: false
    t.text "additional_information"
    t.jsonb "evidence_ruleset", default: []
    t.jsonb "evidence_prompts", default: []
    t.datetime "evidence_last_run_at"
    t.index ["office_code"], name: "index_crime_applications_on_office_code"
    t.index ["usn"], name: "index_crime_applications_on_usn", unique: true
  end

  create_table "dependants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "crime_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "age"
    t.index ["crime_application_id"], name: "index_dependants_on_crime_application_id"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "submitted_at"
    t.datetime "deleted_at"
    t.uuid "crime_application_id", null: false
    t.jsonb "annotations", default: {}, null: false
    t.string "s3_object_key"
    t.string "filename"
    t.string "file_category"
    t.string "content_type"
    t.integer "file_size"
    t.string "scan_provider"
    t.enum "scan_status", default: "awaiting", enum_type: "virus_scan_status"
    t.string "scan_output"
    t.datetime "scan_at"
    t.index ["crime_application_id"], name: "index_documents_on_crime_application_id"
  end

  create_table "incomes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "crime_application_id", null: false
    t.string "income_above_threshold"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_owns_property"
    t.string "has_frozen_income_or_assets"
    t.string "lost_job_in_custody"
    t.date "date_job_lost"
    t.string "manage_without_income"
    t.string "manage_other_details"
    t.string "employment_status", default: [], array: true
    t.string "ended_employment_within_three_months"
    t.string "client_has_dependants"
    t.string "has_savings"
    t.string "has_no_income_payments"
    t.string "has_no_income_benefits"
    t.index ["crime_application_id"], name: "index_incomes_on_crime_application_id"
  end

  create_table "investments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "crime_application_id", null: false
    t.string "investment_type", null: false
    t.bigint "value"
    t.text "description"
    t.string "ownership_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crime_application_id"], name: "index_investments_on_crime_application_id"
  end

  create_table "iojs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "types", default: [], array: true
    t.text "loss_of_liberty_justification"
    t.text "suspended_sentence_justification"
    t.text "loss_of_livelihood_justification"
    t.text "reputation_justification"
    t.text "question_of_law_justification"
    t.text "understanding_justification"
    t.text "witness_tracing_justification"
    t.text "expert_examination_justification"
    t.text "interest_of_another_justification"
    t.text "other_justification"
    t.uuid "case_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "passport_override", default: false
    t.index ["case_id"], name: "index_iojs_on_case_id", unique: true
  end

  create_table "national_savings_certificates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "crime_application_id", null: false
    t.string "certificate_number"
    t.bigint "value"
    t.string "holder_number"
    t.string "ownership_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crime_application_id"], name: "index_national_savings_certificates_on_crime_application_id"
  end

  create_table "offence_dates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "charge_id", null: false
    t.date "date_from"
    t.date "date_to"
    t.index ["charge_id"], name: "index_offence_dates_on_charge_id"
  end

  create_table "outgoings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "crime_application_id", null: false
    t.string "outgoings_more_than_income"
    t.string "how_manage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "income_tax_rate_above_threshold"
    t.string "housing_payment_type"
    t.string "pays_council_tax"
    t.string "has_no_other_outgoings"
    t.index ["crime_application_id"], name: "index_outgoings_on_crime_application_id", unique: true
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "crime_application_id", null: false
    t.string "type", null: false
    t.string "payment_type", null: false
    t.bigint "amount", null: false
    t.string "frequency", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crime_application_id", "type", "payment_type"], name: "index_payments_crime_application_id_and_payment_type", unique: true
    t.index ["crime_application_id"], name: "index_payments_on_crime_application_id"
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
    t.string "benefit_type"
    t.string "has_benefit_evidence"
    t.string "will_enter_nino"
    t.string "can_submit_without_nino"
    t.date "last_jsa_appointment_date"
    t.string "residence_type"
    t.string "relationship_to_someone_else"
    t.index ["crime_application_id"], name: "index_people_on_crime_application_id", unique: true
  end

  create_table "properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "crime_application_id", null: false
    t.string "property_type", null: false
    t.string "house_type"
    t.string "other_house_type"
    t.integer "size_in_acres"
    t.string "usage"
    t.integer "bedrooms"
    t.bigint "value"
    t.bigint "outstanding_mortgage"
    t.decimal "percentage_applicant_owned"
    t.decimal "percentage_partner_owned"
    t.string "is_home_address"
    t.string "has_other_owners"
    t.jsonb "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crime_application_id"], name: "index_properties_on_crime_application_id"
  end

  create_table "property_owners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "property_id", null: false
    t.string "name"
    t.string "relationship"
    t.string "other_relationship"
    t.decimal "percentage_owned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_property_owners_on_property_id"
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth_provider", null: false
    t.string "uid", null: false
    t.string "email"
    t.string "description"
    t.string "roles", default: [], null: false, array: true
    t.string "office_codes", default: [], null: false, array: true
    t.jsonb "settings", default: {}, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.index ["auth_provider", "uid"], name: "index_providers_on_auth_provider_and_uid", unique: true
  end

  create_table "savings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "crime_application_id", null: false
    t.string "saving_type", null: false
    t.string "provider_name"
    t.string "sort_code"
    t.string "account_number"
    t.bigint "account_balance"
    t.string "is_overdrawn"
    t.string "are_wages_paid_into_account"
    t.string "ownership_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crime_application_id"], name: "index_savings_on_crime_application_id"
  end

  add_foreign_key "addresses", "people"
  add_foreign_key "capitals", "crime_applications"
  add_foreign_key "cases", "crime_applications"
  add_foreign_key "charges", "cases"
  add_foreign_key "codefendants", "cases"
  add_foreign_key "dependants", "crime_applications"
  add_foreign_key "documents", "crime_applications"
  add_foreign_key "incomes", "crime_applications"
  add_foreign_key "investments", "crime_applications"
  add_foreign_key "iojs", "cases"
  add_foreign_key "national_savings_certificates", "crime_applications"
  add_foreign_key "offence_dates", "charges"
  add_foreign_key "outgoings", "crime_applications"
  add_foreign_key "payments", "crime_applications"
  add_foreign_key "people", "crime_applications"
  add_foreign_key "properties", "crime_applications"
  add_foreign_key "property_owners", "properties"
  add_foreign_key "savings", "crime_applications"
end
