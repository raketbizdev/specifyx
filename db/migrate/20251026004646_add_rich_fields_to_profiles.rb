class AddRichFieldsToProfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :headline, :string
    add_column :profiles, :summary, :text
    add_column :profiles, :location_city, :string
    add_column :profiles, :location_country, :string
    add_column :profiles, :open_to_relocation, :boolean
    add_column :profiles, :open_to_remote, :boolean
    add_column :profiles, :work_authorization, :string
    add_column :profiles, :seniority_level, :string
    add_column :profiles, :public_handle, :string
    add_column :profiles, :avatar_url, :string
    add_column :profiles, :banner_url, :string
    add_column :profiles, :website_url, :string
    add_column :profiles, :linkedin_url, :string
    add_column :profiles, :github_url, :string
    add_column :profiles, :portfolio_url, :string
    add_column :profiles, :is_public, :boolean
    add_column :profiles, :allow_contact, :boolean
    add_column :profiles, :show_fullname, :boolean
    add_column :profiles, :desired_role_primary, :string
    add_column :profiles, :desired_role_secondary, :string
    add_column :profiles, :employment_type_preference, :string
    add_column :profiles, :min_salary_expectation, :integer
    add_column :profiles, :salary_currency, :string
    add_column :profiles, :availability_status, :string
    add_column :profiles, :available_from, :date
    add_column :profiles, :profile_completion_score, :integer
    add_column :profiles, :match_strength_score, :integer
    add_column :profiles, :reputation_score, :integer
    add_column :profiles, :verified_identity, :boolean
    add_column :profiles, :verified_skills, :boolean
    add_column :profiles, :last_active_at, :datetime
    add_column :profiles, :last_edited_at, :datetime
  end
end
