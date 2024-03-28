class AddColumnHasNoOtherAssetsToCapitals < ActiveRecord::Migration[7.0]
  def change
    change_table :capitals do |t|
      t.string :has_no_other_assets
    end
  end
end
