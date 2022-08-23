class ApplicationStatus < ValueObject
  VALUES = [
    INITIALISED = new(:initialised),
    IN_PROGRESS = new(:in_progress),
    SUBMITTED   = new(:submitted)
  ].freeze

  def self.enum_values
    values.to_h { |value| [value.to_sym, value.to_s] }
  end

  def self.viewable_statuses
    [IN_PROGRESS.to_s, SUBMITTED.to_s]
  end
end
