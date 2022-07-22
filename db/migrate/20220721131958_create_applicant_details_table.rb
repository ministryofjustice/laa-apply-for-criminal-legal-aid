class CreateApplicantDetailsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :applicant_details, id: :uuid do |t|
      t.timestamps

      t.references :crime_application, type: :uuid, foreign_key: true, null: false, index: { unique: true }

      t.string :first_name
      t.string :last_name
      t.string :other_names
      t.date   :date_of_birth
      t.string :has_nino
      t.string :nino
    end
  end
end
