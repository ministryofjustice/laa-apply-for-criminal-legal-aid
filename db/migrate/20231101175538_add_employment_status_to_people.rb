class AddEmploymentStatusToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :employment_status, :string
    add_column :people, :ended_employment_within_three_months, :boolean
  end
end
