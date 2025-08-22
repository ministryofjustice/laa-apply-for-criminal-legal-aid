class AddSoftDeletedAtToCrimeApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :crime_applications, :soft_deleted_at, :datetime
  end
end
