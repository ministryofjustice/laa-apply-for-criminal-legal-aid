class AddHadFrozenIncomeOrAssetsToCapitalDetails < ActiveRecord::Migration[7.0]
  def change
    change_table :capitals do |t|
      t.string :has_frozen_income_or_assets
    end
  end
end
