class SetDefaultApplicationStatus < ActiveRecord::Migration[7.0]
  def change
    change_column_default :crime_applications, :status, :in_progress
  end
end
