class AddWillEnterNinoAttribute < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :will_enter_nino, :string
  end
end
