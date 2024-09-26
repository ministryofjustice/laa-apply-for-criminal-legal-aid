class RetainDatestampedDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :crime_applications, :date_stamp_context, :jsonb, default: nil
  end
end
