class ModifyIncomeDetailsToRefCrimeApplication < ActiveRecord::Migration[7.0]
  def change
    change_table :income_details do |t|
      t.remove_foreign_key :people

      # Ref crime_application rather than person
      t.rename :person_id, :crime_application_id
    end

    add_foreign_key :income_details, :crime_applications, column: :crime_application_id
  end
end
