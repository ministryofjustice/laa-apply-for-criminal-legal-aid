class AddSubmissionHexdigestToCrimeApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :crime_applications, :submission_hexdigest, :string
    add_column :crime_applications, :submission_updated_at, :datetime
  end
end
