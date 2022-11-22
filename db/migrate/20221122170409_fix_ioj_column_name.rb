class FixIojColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :iojs, :loss_of_livelyhood_justification, :loss_of_livelihood_justification
  end
end
