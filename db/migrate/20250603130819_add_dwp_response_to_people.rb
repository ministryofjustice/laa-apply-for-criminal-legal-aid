class AddDWPResponseToPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :people, :dwp_response, :string
  end
end
