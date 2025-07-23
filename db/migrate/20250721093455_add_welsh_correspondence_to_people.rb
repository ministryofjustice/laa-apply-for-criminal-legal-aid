class AddWelshCorrespondenceToPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :people, :welsh_correspondence, :string
  end
end
