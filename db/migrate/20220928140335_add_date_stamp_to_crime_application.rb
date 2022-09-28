class AddDateStampToCrimeApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :date_stamp, :datetime
  end
end
