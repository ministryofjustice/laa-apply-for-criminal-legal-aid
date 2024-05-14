class AddNewAttributes < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :ownership_type, :string, default: OwnershipType::APPLICANT.to_s

    add_column :people, :relationship_to_partner, :string
    add_column :people, :separation_date, :string
    add_column :people, :relationship_status, :date
    add_column :people, :has_partner, :string, default: YesNoAnswer::NO.to_s

    add_column :people, :involvement_in_case, :string
    add_column :people, :conflict_of_interest, :string
    add_column :people, :has_same_address_as_client, :string

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
  end
end
