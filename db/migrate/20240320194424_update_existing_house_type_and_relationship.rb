class UpdateExistingHouseTypeAndRelationship < ActiveRecord::Migration[7.0]
  def change
    Property.where(house_type: 'custom').update(house_type: 'other')
    PropertyOwner.where(relationship: 'custom').update(relationship: 'other')
  end
end
