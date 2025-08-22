class DeletionReason < ValueObject
  VALUES = [
    PROVIDER_ACTION = new(:provider_action),
    RETENTION_RULE = new(:retention_rule),
  ].freeze
end
