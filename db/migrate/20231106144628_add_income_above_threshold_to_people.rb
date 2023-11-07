class AddIncomeAboveThresholdToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :income_above_threshold, :string
  end
end
