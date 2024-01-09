class AddIsMeansTestedToCrimeApplication < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :is_means_tested, :string
  end
end
