class AddEmploymentStatusToIncomeDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :income_details, :employment_status, :string, array: true, default: []
    add_column :income_details, :ended_employment_within_three_months, :string
  end
end
