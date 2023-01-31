class ApplicationStatus < ValueObject
  VALUES = [
    IN_PROGRESS = new(:in_progress),
    SUBMITTED   = new(:submitted),
    RETURNED    = new(:returned),
    SUPERSEDED  = new(:superseded),
  ].freeze

  LOCALLY_PERSISTED_STATUSES = [
    IN_PROGRESS,
  ].freeze

  def self.enum_values
    LOCALLY_PERSISTED_STATUSES.map(&:value).index_with(&:to_s)
  end
end
