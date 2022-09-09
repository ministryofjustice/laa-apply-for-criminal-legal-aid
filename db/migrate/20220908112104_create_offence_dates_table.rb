class CreateOffenceDatesTable < ActiveRecord::Migration[7.0]
  def change
    create_table :offence_dates, id: :uuid do |t|
      t.timestamps

      t.references :charge, type: :uuid, foreign_key: true, null: false

      t.date :date
    end
  end
end
