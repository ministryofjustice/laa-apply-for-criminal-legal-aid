module Summary
  module Components
    class AmountAndFrequencyAnswer < BaseAnswer
      def answer_text
        return if value&.amount.blank? || value&.frequency.blank?

        simple_format(
          I18n.t(
            'summary.dictionary.amount_and_frequency_answer',
            amount: number_to_currency(value.amount),
            frequency: value.frequency.to_phrase
          ),
          { class: 'govuk-body' }
        )
      end
    end
  end
end
