class AddCaseTypeToCase < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :case_type, :string
  end
end
