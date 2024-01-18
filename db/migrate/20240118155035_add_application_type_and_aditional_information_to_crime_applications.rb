class AddApplicationTypeAndAditionalInformationToCrimeApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :application_type, :string, null: false, default: ApplicationType::INITIAL.to_s
    add_column :crime_applications, :additional_information, :text
  end
end
