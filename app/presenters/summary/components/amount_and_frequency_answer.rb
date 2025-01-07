module Summary
  module Components
    class AmountAndFrequencyAnswer < BaseAnswer
      def answer_text
        return if value&.amount.blank? || value&.frequency.blank?

        simple_format(
          I18n.t(
            'summary.dictionary.amount_and_frequency_answer',
            amount: number_to_currency(value.amount.to_s),
            frequency: PaymentFrequencyType.to_phrase(value.frequency)
          ),
          { class: 'govuk-body' }
        )
      end
    end
  end
end
