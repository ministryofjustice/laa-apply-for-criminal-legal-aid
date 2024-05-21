class RenamePassportingBenefitInPeople < ActiveRecord::Migration[7.0]
  def change
    rename_column :people, :passporting_benefit, :benefit_check_result
  end
end
