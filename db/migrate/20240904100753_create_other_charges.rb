class CreateOtherCharges < ActiveRecord::Migration[7.0]
  def change
    create_table :other_charges, id: :uuid do |t|
      t.references :case, type: :uuid, foreign_key: true, null: false
      t.text :charge
      t.string :hearing_court_name
      t.date :next_hearing_date
      t.string :ownership_type, null: false, default: "applicant"

      t.timestamps
    end
  end
end
