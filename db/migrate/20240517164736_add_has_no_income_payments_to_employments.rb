class AddHasNoIncomePaymentsToEmployments < ActiveRecord::Migration[7.0]
  def change
    add_column :employments, :has_no_deductions, :string
  end
end
