class ChangeDateJobLostDataTypeOnPeople < ActiveRecord::Migration[7.0]
  def change
    change_column(:people, :date_job_lost, :date)
  end
end
