class DropOffencesTable < ActiveRecord::Migration[7.0]
  def change
    remove_reference :charges, :offence, type: :string, foreign_key: true
    drop_table :offences, id: :string
  end
end
