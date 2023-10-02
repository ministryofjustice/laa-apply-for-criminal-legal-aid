class AddFirstCourtHearingAttributes < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :is_first_court_hearing, :string
    add_column :cases, :first_court_hearing_name, :string
  end
end
