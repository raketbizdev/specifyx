class CreateLanguages < ActiveRecord::Migration[7.2]
  def change
    create_table :languages do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :language_name
      t.string :proficiency

      t.timestamps
    end
  end
end
