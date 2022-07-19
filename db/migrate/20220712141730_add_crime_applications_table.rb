class AddCrimeApplicationsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :crime_applications, id: :uuid do |t|
      t.string :navigation_stack, array: true, default: []
      t.timestamps
    end
  end
end
