class AddDeclaredContentTypeToDocuments < ActiveRecord::Migration[7.2]
  def change
    add_column :documents, :declared_content_type, :string
  end
end
