class AddProviderDetailsToApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :provider_details, :jsonb, null: false, default: {}

    remove_column :crime_applications, :legal_rep_first_name, :string
    remove_column :crime_applications, :legal_rep_last_name, :string
    remove_column :crime_applications, :legal_rep_telephone, :string
  end
end
