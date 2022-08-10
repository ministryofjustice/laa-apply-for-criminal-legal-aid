class AddCorrespondenceAddressToPeople < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :correspondence_address_type, :string
  end
end
