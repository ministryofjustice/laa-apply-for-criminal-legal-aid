class AddMeansPassportField < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :means_passport, :string, array: true, default: []
  end
end
