class AddInvolvedInCaseToPartner < ActiveRecord::Migration[7.0]
  def change
    add_column :partner_details, :involved_in_case, :string
  end
end
