class UsnSeqHelper
  # More details about USN, the sequence start, etc:
  # https://dsdmoj.atlassian.net/wiki/spaces/CRIMAP/pages/4210524301/USN

  USN_SEQUENCE_NAME  = 'crime_applications_usn_seq'.freeze
  USN_SEQUENCE_START = 6_000_000

  class << self
    # Sequence configuration is not be captured in the `schema.rb`.
    # The alternative to this would be to stop using `schema.rb`
    # and move towards using `structure.sql` instead.
    #
    # But even with `structure.sql`, there are some gotchas to
    # bear in mind:
    #
    # When reconstructing the database from the `schema.rb` (or
    # `structure.sql`) by doing `db:schema:load`, `db:prepare`
    # or `db:setup`, the sequence will be reset back to 1.
    #
    # If the database setup is done with a 2-steps approach,
    # first `db:create` and then `db:migrate`, then the migration
    # will configure the sequence to start back at 6_000_000.
    #
    # In both scenarios, this might not be desirable.
    # If using this helper, the `USN_SEQ_START` env variable can
    # be used to override the default sequence start.
    #
    # In production, once we have real data, I can't foresee a
    # scenario where we would be doing any of the above. If we
    # are doing so, it means we are starting fresh, with no DB.
    # Also note, that doing `db:prepare` on an existing DB will
    # not recreate it. Prepare runs setup if database does not
    # exist, or runs migrations if it does.
    #
    # In case of catastrophic failure of the database or
    # corruption of data, we would have to restore from a backup
    # at a point in time, which would reset everything back to
    # how it was at that moment, including the sequence numbering
    # whatever that is by then (i.e. 6_789_567).
    #
    def create_sequence
      ActiveRecord::Base.connection.execute(
        "CREATE SEQUENCE IF NOT EXISTS #{USN_SEQUENCE_NAME} AS integer START WITH #{seq_start}"
      )
    end

    def drop_sequence
      raise 'The Rails environment is running in production mode!' if Rails.env.production?

      ActiveRecord::Base.connection.execute(
        "DROP SEQUENCE IF EXISTS #{USN_SEQUENCE_NAME}"
      )
    end

    def restart_sequence
      puts "Restarting USN sequence with #{seq_start}..."

      ActiveRecord::Base.connection.execute(
        "ALTER SEQUENCE IF EXISTS public.#{USN_SEQUENCE_NAME} RESTART WITH #{seq_start}"
      )
    end

    private

    def seq_start
      ENV.fetch('USN_SEQ_START', USN_SEQUENCE_START)
    end
  end
end
