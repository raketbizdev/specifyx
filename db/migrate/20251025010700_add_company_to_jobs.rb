class AddCompanyToJobs < ActiveRecord::Migration[7.2]
  def change
    add_reference :jobs, :company, null: false, foreign_key: true
  end
end
