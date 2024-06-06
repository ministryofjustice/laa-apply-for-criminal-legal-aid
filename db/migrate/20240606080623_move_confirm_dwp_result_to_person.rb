class MoveConfirmDWPResultToPerson < ActiveRecord::Migration[7.0]
  def change
    remove_column :crime_applications, :confirm_dwp_result
    add_column :people, :confirm_dwp_result, :string
  end
end
