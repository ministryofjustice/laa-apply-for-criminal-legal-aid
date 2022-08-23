class AddStatusToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :status, :string
  end
end
