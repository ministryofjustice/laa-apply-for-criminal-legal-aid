class AddOfficeCodeToApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :office_code, :string
    add_index :crime_applications, :office_code
  end
end
