class AddPreCifcReason < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :pre_cifc_reason, :string
  end
end
