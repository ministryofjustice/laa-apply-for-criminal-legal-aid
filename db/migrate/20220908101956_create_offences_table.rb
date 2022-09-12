class CreateOffencesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :offences, id: :string do |t|
      t.timestamps

      t.string :name, null: false
      t.string :offence_class, null: false
      t.string :offence_type, null: false

      # Rank based on number of occurrences as per Aug 2019 analysis
      t.integer :rank

      # How many times an offence has been chosen in our service
      t.integer :frequency, default: 0, null: false
    end
  end
end
