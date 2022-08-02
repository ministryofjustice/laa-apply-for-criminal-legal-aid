class DropApplicantDetailsTable < ActiveRecord::Migration[7.0]
  def up
    drop_table :applicant_details
  end

  def down
    create_table :applicant_details, id: :uuid
  end
end
