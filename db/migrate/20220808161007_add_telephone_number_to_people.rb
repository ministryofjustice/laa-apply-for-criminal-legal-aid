class AddTelephoneNumberToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :telephone_number, :string
  end
end
