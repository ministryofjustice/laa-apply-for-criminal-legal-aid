class RemoveDeclarationSignedField < ActiveRecord::Migration[7.0]
  def change
    remove_column :crime_applications, :declaration_signed, :boolean
  end
end
