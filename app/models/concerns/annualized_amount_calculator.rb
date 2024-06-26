module AnnualizedAmountCalculator
  extend ActiveSupport::Concern

  def annualized_amount # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
    return amount if amount.nil? || amount.zero?

    prorated_value =
      case frequency
      when PaymentFrequencyType::WEEKLY.to_s
        (amount.value * 52)
      when PaymentFrequencyType::FORTNIGHTLY.to_s
        (amount.value * 26)
      when PaymentFrequencyType::FOUR_WEEKLY.to_s
        (amount.value * 13)
      when PaymentFrequencyType::MONTHLY.to_s
        (amount.value * 12)
      when PaymentFrequencyType::ANNUALLY.to_s
        amount.value
      end

    Money.new(prorated_value)
  end
end
