class AddDeclarationSignedField < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :declaration_signed, :boolean
  end
end
