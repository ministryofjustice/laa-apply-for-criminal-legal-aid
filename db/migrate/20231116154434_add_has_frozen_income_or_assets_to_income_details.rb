class AddHasFrozenIncomeOrAssetsToIncomeDetails < ActiveRecord::Migration[7.0]
  def change
    change_table :income_details do |t|
      t.string :has_frozen_income_or_assets
    end
  end
end
