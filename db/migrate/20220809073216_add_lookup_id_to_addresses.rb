class AddLookupIdToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :lookup_id, :string
  end
end
