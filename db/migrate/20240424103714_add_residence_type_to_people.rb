class AddResidenceTypeToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :residence_type, :string
    add_column :people, :relationship_to_someone_else, :string
  end
end
