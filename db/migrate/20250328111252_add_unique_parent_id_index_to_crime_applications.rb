class AddUniqueParentIdIndexToCrimeApplications < ActiveRecord::Migration[7.2]
  def change
    add_index :crime_applications, :parent_id, unique: true
  end
end
