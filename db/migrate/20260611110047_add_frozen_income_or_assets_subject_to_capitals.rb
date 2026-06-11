class AddFrozenIncomeOrAssetsSubjectToCapitals < ActiveRecord::Migration[8.1]
  def change
    add_column :capitals, :frozen_income_or_assets_subject, :string
  end
end
