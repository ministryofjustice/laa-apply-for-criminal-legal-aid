class ApplicationStatus < ValueObject
  VALUES = [
    NEWLY_INITIALISED = new(:newly_initialised),
    IN_PROGRESS       = new(:in_progress),
    COMPLETED         = new(:completed)
  ].freeze
end
