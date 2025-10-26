class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :role
      t.string :tech_stack
      t.date :start_date
      t.date :end_date
      t.boolean :is_public
      t.string :project_url

      t.timestamps
    end
  end
end
