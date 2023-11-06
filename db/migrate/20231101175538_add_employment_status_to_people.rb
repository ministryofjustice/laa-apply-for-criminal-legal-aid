class AddEmploymentStatusToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :employment_status, :string, array: true, default: []
    add_column :people, :ended_employment_within_three_months, :string
  end
end
