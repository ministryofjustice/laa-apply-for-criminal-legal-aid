class ChangeColumnTypeInProperties < ActiveRecord::Migration[7.0]
  def up
    change_column :properties, :percentage_applicant_owned, :decimal
    change_column :properties, :percentage_partner_owned, :decimal
  end

  def down
    change_column :properties, :percentage_applicant_owned, :integer
    change_column :properties, :percentage_partner_owned, :integer
  end
end
