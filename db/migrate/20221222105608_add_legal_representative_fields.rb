class AddLegalRepresentativeFields < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :legal_rep_first_name, :string
    add_column :crime_applications, :legal_rep_last_name, :string
    add_column :crime_applications, :legal_rep_telephone, :string
  end
end
