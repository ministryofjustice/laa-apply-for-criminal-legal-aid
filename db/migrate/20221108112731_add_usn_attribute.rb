class AddUsnAttribute < ActiveRecord::Migration[7.0]
  def up
    UsnSeqHelper.create_sequence

    add_column :crime_applications, :usn, :integer, null: false,
               default: -> { "nextval('#{UsnSeqHelper::USN_SEQUENCE_NAME}')" }

    add_index :crime_applications, :usn, unique: true
  end

  # On rollback, we do not remove the sequence on purpose!
  # This is a precaution so worst case scenario we don't
  # end up with re-used USNs.
  def down
    remove_column :crime_applications, :usn
  end
end
