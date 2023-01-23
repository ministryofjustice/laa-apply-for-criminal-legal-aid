class AddParentIdToApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :parent_id, :uuid
  end
end
