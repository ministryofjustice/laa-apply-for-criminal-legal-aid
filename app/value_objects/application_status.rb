class ApplicationStatus < ValueObject
  VALUES = [
    INITIALISED = new(:initialised),
    IN_PROGRESS = new(:in_progress),
    COMPLETE = new(:complete),
  ].freeze
end
