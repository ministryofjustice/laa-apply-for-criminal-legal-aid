class ChangePeopleIndexToBePolymorphic < ActiveRecord::Migration[7.0]
  def change
    remove_index :people, :crime_application_id, unique: true

    add_index :people, [:type, :crime_application_id], unique: true
  end
end
