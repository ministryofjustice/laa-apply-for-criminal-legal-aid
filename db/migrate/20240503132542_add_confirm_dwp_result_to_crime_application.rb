class AddConfirmDWPResultToCrimeApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :confirm_dwp_result, :string
  end
end
