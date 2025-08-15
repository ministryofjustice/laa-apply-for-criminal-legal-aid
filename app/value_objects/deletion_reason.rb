class DeletionReason < ValueObject
  VALUES = [
    MANUAL = new(:manual),
    SYSTEM_AUTOMATED = new(:system_automated),
  ].freeze
end
