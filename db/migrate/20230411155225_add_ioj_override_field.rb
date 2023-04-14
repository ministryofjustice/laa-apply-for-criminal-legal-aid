class AddIojOverrideField < ActiveRecord::Migration[7.0]
  def change
    add_column :iojs, :passport_override, :boolean, default: false
  end
end
