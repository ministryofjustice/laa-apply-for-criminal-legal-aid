class AddExemptFromDeletionToCrimeApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :crime_applications, :exempt_from_deletion, :boolean, default: false
  end
end
