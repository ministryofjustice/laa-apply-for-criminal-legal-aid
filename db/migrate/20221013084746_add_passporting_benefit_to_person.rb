class AddPassportingBenefitToPerson < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :passporting_benefit, :boolean
  end
end
