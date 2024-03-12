class PaymentFrequencyType < ValueObject
  VALUES = [
    WEEKLY = new(:week),
    FORTNIGHTLY = new(:fortnight),
    FOUR_WEEKLY = new(:four_weeks),
    MONTHLY = new(:month),
    ANNUALLY = new(:annual),
  ].freeze

  def self.to_phrase(value)
    return '' unless value

    I18n.t("helpers/dictionary.frequency_phrases.#{value}")
  end

  def to_phrase
    I18n.t("helpers/dictionary.frequency_phrases.#{self}")
  end
end
