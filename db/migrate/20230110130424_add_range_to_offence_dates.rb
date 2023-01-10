class AddRangeToOffenceDates < ActiveRecord::Migration[7.0]
  def change
    add_column :offence_dates, :date_from, :date
    add_column :offence_dates, :date_to, :date

    remove_column :offence_dates, :date, :date
  end
end
