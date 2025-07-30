class ScanValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    perform_validations
  end

  private

  # rubocop:disable Style/GuardClause, Style/IfUnlessModifier
  def perform_validations
    if Datastore::Documents::Scan.inconclusive?(record)
      record.errors.add(:scan_status, :inconclusive)
    end

    if Datastore::Documents::Scan.flagged?(record)
      record.errors.add(:scan_status, :flagged)
    end
  end
  # rubocop:enable Style/GuardClause, Style/IfUnlessModifier
end
