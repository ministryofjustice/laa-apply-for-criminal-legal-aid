class AddSubmittedAtField < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :submitted_at, :datetime
  end
end
