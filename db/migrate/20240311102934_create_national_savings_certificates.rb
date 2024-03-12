class CreateNationalSavingsCertificates < ActiveRecord::Migration[7.0]
  def change
    create_table :national_savings_certificates, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false

      t.string :certificate_number
      t.integer :value
      t.string :holder_number
      t.string :ownership_type

      t.timestamps
    end

    add_column :capitals, :has_national_savings_certificates, :string
  end
end
