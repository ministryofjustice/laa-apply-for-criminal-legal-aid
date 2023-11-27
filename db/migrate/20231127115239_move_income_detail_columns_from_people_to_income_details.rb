class MoveIncomeDetailColumnsFromPeopleToIncomeDetails < ActiveRecord::Migration[7.0]
  def change
    remove_column :people, :lost_job_in_custody, :string
    remove_column :people, :date_job_lost, :date
    remove_column :people, :manage_without_income, :string
    remove_column :people, :manage_other_details, :string
    remove_column :people, :employment_status, :string, array: true, default: []
    remove_column :people, :ended_employment_within_three_months, :string

    add_column :income_details, :lost_job_in_custody, :string
    add_column :income_details, :date_job_lost, :date, using: 'date_job_lost::date'
    add_column :income_details, :manage_without_income, :string
    add_column :income_details, :manage_other_details, :string
    add_column :income_details, :employment_status, :string, array: true, default: []
    add_column :income_details, :ended_employment_within_three_months, :string
  end
end
