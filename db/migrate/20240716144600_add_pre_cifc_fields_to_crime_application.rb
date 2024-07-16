class AddPreCifcFieldsToCrimeApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :pre_cifc_reference_number, :string
    add_column :crime_applications, :pre_cifc_usn, :string
    add_column :crime_applications, :pre_cifc_maat_id, :string
  end
end
