class AddConfirmDetailsAttributeToApplicant < ActiveRecord::Migration[7.0]
  def change
    add_column :people, :confirm_details, :string
  end
end
