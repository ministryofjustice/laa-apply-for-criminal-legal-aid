class AddCouncilTaxToOutgoings < ActiveRecord::Migration[7.0]
  def change
    add_column :outgoings, :pays_council_tax, :string
    add_column :outgoings, :council_tax_amount, :integer
  end
end
