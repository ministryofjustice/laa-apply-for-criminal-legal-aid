class AddBenefitTypeToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :benefit_type, :string
  end
end
