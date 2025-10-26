class CreateAchievements < ActiveRecord::Migration[7.2]
  def change
    create_table :achievements do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :title
      t.string :issuer
      t.date :awarded_on
      t.text :description

      t.timestamps
    end
  end
end
