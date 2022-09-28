class AddCourtHearingFieldsToCases < ActiveRecord::Migration[7.0]
  def change
    add_column :cases, :hearing_court_name, :string
    add_column :cases, :hearing_date, :date
  end
end
