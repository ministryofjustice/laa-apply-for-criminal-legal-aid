class AddNewAttributes < ActiveRecord::Migration[7.0]
  def change
    create_table :partner_details, id: :uuid do |t|
      t.references :crime_application, type: :uuid, foreign_key: true, null: false, index: { unique: true }

      t.string :relationship_to_partner
      t.string :involvement_in_case
      t.string :conflict_of_interest
      t.string :has_same_address_as_client
      t.string :relationship_status
      t.date :separation_date
      t.string :has_partner, default: YesNoAnswer::NO.to_s, null: false

      # Not assigned until partner personal details collected
      t.uuid :partner_id, foreign_key: true, null: true, uniq: true

      t.timestamps
    end

    add_column :payments, :ownership_type, :string, default: OwnershipType::APPLICANT.to_s

    add_column :incomes, :partner_employment_status, :string, array: true, default: []
    add_column :incomes, :partner_has_no_income_payments, :string
    add_column :incomes, :partner_has_no_income_benefits, :string

    add_column :outgoings, :partner_income_tax_rate_above_threshold, :string

    add_column :capitals, :partner_will_benefit_from_trust_fund, :string
    add_column :capitals, :partner_trust_fund_yearly_dividend, :bigint
    add_column :capitals, :partner_trust_fund_amount_held, :bigint
    add_column :capitals, :partner_has_premium_bonds, :string
    add_column :capitals, :partner_premium_bonds_total_value, :bigint
    add_column :capitals, :partner_premium_bonds_holder_number, :string

    # Reset People/CrimeApplication index to include type column for STI
    remove_index :people, column: [:crime_application_id], name: 'index_people_on_crime_application_id'
    add_index :people, [:type, :crime_application_id], unique: true
  end
end
