class CreateCertifications < ActiveRecord::Migration[7.2]
  def change
    create_table :certifications do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :name
      t.string :issuer
      t.date :issued_on
      t.date :expires_on
      t.string :credential_id
      t.string :credential_url

      t.timestamps
    end
  end
end
