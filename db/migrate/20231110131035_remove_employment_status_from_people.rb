class RemoveEmploymentStatusFromPeople < ActiveRecord::Migration[7.0]
  def change
    remove_column :people, :employment_status, :string, array: true, default: []
    remove_column :people, :ended_employment_within_three_months, :string
  end
end
