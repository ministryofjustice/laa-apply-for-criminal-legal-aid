class PaymentFrequencyType < ValueObject
  VALUES = [
    WEEKLY = new(:weekly),
    FORTNIGHTLY = new(:fortnightly),
    FOUR_WEEKLY = new(:four_weekly),
    MONTHLY = new(:monthly),
    YEARLY = new(:yearly),
  ].freeze
end
