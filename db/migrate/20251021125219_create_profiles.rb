class CreateProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }  # <— unique here
      t.string  :first_name
      t.string  :last_name
      t.string  :display_name
      t.text    :bio
      t.text    :skills
      t.boolean :public, default: false, null: false
      t.string  :slug
      t.timestamps
    end

    add_index :profiles, :slug, unique: true
  end
end
