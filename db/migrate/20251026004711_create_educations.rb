class CreateEducations < ActiveRecord::Migration[7.2]
  def change
    create_table :educations do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :school_name
      t.string :degree
      t.string :field_of_study
      t.date :start_date
      t.date :end_date
      t.boolean :is_current
      t.text :notes

      t.timestamps
    end
  end
end
