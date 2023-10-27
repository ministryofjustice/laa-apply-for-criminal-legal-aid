class AddLostJobInCustodyToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :lost_job_in_custody, :string
    add_column :people, :date_job_lost, :string
  end
end
