class CreateExperiences < ActiveRecord::Migration[7.2]
  def change
    create_table :experiences do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :job_title
      t.string :company_name
      t.string :company_location
      t.string :employment_type
      t.date :start_date
      t.date :end_date
      t.boolean :is_current
      t.text :impact_summary

      t.timestamps
    end
  end
end
