class UpdateColumnsForEmployments < ActiveRecord::Migration[7.0]
  def change
    remove_reference  :employments, :payment, type: :uuid
    add_column :employments, :amount,  :bigint
    add_column :employments, :frequency,  :string
    add_column :employments, :metadata,  :jsonb, default: {}, null: false
  end
end
