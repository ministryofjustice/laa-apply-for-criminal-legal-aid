class AddApplicationTypeToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :application_type, :string, null: false, default: ApplicationType::INITIAL.to_s
  end
end
