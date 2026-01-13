class AddSubmissionHexdigestToCrimeApplications < ActiveRecord::Migration[7.2]
  def up
    add_column :crime_applications, :submission_hexdigest, :string
    add_column :crime_applications, :submission_updated_at, :datetime

    execute <<~SQL.squish
      UPDATE crime_applications
      SET submission_updated_at = updated_at
      WHERE submission_updated_at IS NULL;
    SQL

    add_index :crime_applications, :submission_updated_at
  end

  def down
    remove_index :crime_applications, :submission_updated_at, if_exists: true
    remove_column :crime_applications, :submission_hexdigest
    remove_column :crime_applications, :submission_updated_at
  end
end
