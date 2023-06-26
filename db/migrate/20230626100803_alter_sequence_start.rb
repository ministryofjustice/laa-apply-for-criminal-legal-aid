class AlterSequenceStart < ActiveRecord::Migration[7.0]
  def up
    UsnSeqHelper.restart_sequence
  end

  # No rollback migration on purpose
end
