class CreateDeductions < ActiveRecord::Migration[7.0]
  def change
    create_table :deductions, id: :uuid do |t|
      t.references :employment, null: false, foreign_key: true, type: :uuid
      t.string :deduction_type, null: false
      t.bigint :amount, null: false
      t.string :frequency, null: false
      t.text :details

      t.timestamps
    end
    add_index :deductions, [:deduction_type, :employment_id], unique: true
  end
end
