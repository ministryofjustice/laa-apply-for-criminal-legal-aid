class AddArcNumberToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :arc, :string
  end
end
