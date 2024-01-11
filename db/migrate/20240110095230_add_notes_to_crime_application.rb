class AddNotesToCrimeApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :notes, :text
  end
end
