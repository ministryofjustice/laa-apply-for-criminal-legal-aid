class ChangeColumnnameCustomToOtherInPropertyAndPropertyOwners < ActiveRecord::Migration[7.0]
  def self.up
    rename_column :properties, :custom_house_type, :other_house_type
    rename_column :property_owners, :custom_relationship, :other_relationship
  end

  def self.down
    rename_column :properties, :other_house_type, :custom_house_type
    rename_column :property_owners, :other_relationship, :custom_relationship
  end
end
