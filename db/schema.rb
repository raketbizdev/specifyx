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

ActiveRecord::Schema[7.2].define(version: 2025_10_26_004919) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievements", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "title"
    t.string "issuer"
    t.date "awarded_on"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_achievements_on_profile_id"
  end

  create_table "certifications", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "name"
    t.string "issuer"
    t.date "issued_on"
    t.date "expires_on"
    t.string "credential_id"
    t.string "credential_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_certifications_on_profile_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "website"
    t.string "slug"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_companies_on_slug", unique: true
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "educations", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "school_name"
    t.string "degree"
    t.string "field_of_study"
    t.date "start_date"
    t.date "end_date"
    t.boolean "is_current"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_educations_on_profile_id"
  end

  create_table "experiences", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "job_title"
    t.string "company_name"
    t.string "company_location"
    t.string "employment_type"
    t.date "start_date"
    t.date "end_date"
    t.boolean "is_current"
    t.text "impact_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_experiences_on_profile_id"
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

  create_table "job_applications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "job_id", null: false
    t.text "cover_letter"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_job_applications_on_job_id"
    t.index ["user_id"], name: "index_job_applications_on_user_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "location"
    t.string "employment_type"
    t.bigint "user_id", null: false
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_jobs_on_company_id"
    t.index ["slug"], name: "index_jobs_on_slug", unique: true
    t.index ["user_id"], name: "index_jobs_on_user_id"
  end

  create_table "languages", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "language_name"
    t.string "proficiency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_languages_on_profile_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "display_name"
    t.text "bio"
    t.text "skills"
    t.boolean "public", default: false, null: false
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "headline"
    t.text "summary"
    t.string "location_city"
    t.string "location_country"
    t.boolean "open_to_relocation"
    t.boolean "open_to_remote"
    t.string "work_authorization"
    t.string "seniority_level"
    t.string "public_handle"
    t.string "avatar_url"
    t.string "banner_url"
    t.string "website_url"
    t.string "linkedin_url"
    t.string "github_url"
    t.string "portfolio_url"
    t.boolean "is_public"
    t.boolean "allow_contact"
    t.boolean "show_fullname"
    t.string "desired_role_primary"
    t.string "desired_role_secondary"
    t.string "employment_type_preference"
    t.integer "min_salary_expectation"
    t.string "salary_currency"
    t.string "availability_status"
    t.date "available_from"
    t.integer "profile_completion_score"
    t.integer "match_strength_score"
    t.integer "reputation_score"
    t.boolean "verified_identity"
    t.boolean "verified_skills"
    t.datetime "last_active_at"
    t.datetime "last_edited_at"
    t.index ["slug"], name: "index_profiles_on_slug", unique: true
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "title"
    t.text "description"
    t.string "role"
    t.string "tech_stack"
    t.date "start_date"
    t.date "end_date"
    t.boolean "is_public"
    t.string "project_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_projects_on_profile_id"
  end

  create_table "skills", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "name"
    t.string "category"
    t.integer "proficiency_level"
    t.boolean "is_primary"
    t.integer "years_experience"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_skills_on_profile_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "achievements", "profiles"
  add_foreign_key "certifications", "profiles"
  add_foreign_key "companies", "users"
  add_foreign_key "educations", "profiles"
  add_foreign_key "experiences", "profiles"
  add_foreign_key "job_applications", "jobs"
  add_foreign_key "job_applications", "users"
  add_foreign_key "jobs", "companies"
  add_foreign_key "jobs", "users"
  add_foreign_key "languages", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "projects", "profiles"
  add_foreign_key "skills", "profiles"
end
