class AddHasArcToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :has_arc, :string
  end
end
