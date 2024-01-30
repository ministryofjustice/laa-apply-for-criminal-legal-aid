class AddAdditionalInformationToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :additional_information, :text
  end
end
