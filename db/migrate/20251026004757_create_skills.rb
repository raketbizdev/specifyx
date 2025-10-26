class CreateSkills < ActiveRecord::Migration[7.2]
  def change
    create_table :skills do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :name
      t.string :category
      t.integer :proficiency_level
      t.boolean :is_primary
      t.integer :years_experience

      t.timestamps
    end
  end
end
