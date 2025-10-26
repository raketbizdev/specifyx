class CreateJobs < ActiveRecord::Migration[7.2]
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.string :location
      t.string :employment_type
      t.references :user, null: false, foreign_key: true
      t.string :slug

      t.timestamps
    end
    add_index :jobs, :slug, unique: true
  end
end
