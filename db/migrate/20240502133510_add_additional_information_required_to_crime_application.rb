class AddAdditionalInformationRequiredToCrimeApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :additional_information_required, :string
  end
end
