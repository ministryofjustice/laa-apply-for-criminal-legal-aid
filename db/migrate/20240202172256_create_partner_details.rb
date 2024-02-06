class CreatePartnerDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :partner_details, id: :uuid do |t|
      t.string :involvement_in_case
      t.string :conflict_of_interest
      t.uuid :partner_id, foreign_key: true, null: false, uniq: true

      t.timestamps
    end
  end
end
