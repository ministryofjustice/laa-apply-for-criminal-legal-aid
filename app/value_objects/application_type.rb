class ApplicationType < ValueObject
  # NOTE: for MVP, all applications are "initial"
  VALUES = [
    INITIAL = new(:initial),
  ].freeze
end
