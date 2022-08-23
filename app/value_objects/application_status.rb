class ApplicationStatus < ValueObject
  VALUES = [
    IN_PROGRESS = new(:in_progress),
    SUBMITTED   = new(:submitted)
  ].freeze

  def self.enum_values
    values.to_h { |value| [value.to_sym, value.to_s] }
  end
end
