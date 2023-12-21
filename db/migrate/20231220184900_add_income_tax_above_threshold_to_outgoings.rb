class AddIncomeTaxAboveThresholdToOutgoings < ActiveRecord::Migration[7.0]
  def change
    add_column :outgoings, :income_tax_rate_above_threshold, :string
  end
end
