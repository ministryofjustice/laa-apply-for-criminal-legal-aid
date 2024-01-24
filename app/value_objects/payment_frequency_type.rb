class PaymentFrequencyType < ValueObject
  VALUES = [
    WEEKLY = new(:week),
    FORTNIGHTLY = new(:fortnight),
    FOUR_WEEKLY = new(:four_weeks),
    MONTHLY = new(:month),
    ANNUALLY = new(:annual),
  ].freeze
end
