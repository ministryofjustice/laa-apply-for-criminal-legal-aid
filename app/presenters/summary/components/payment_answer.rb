module Summary
  module Components
    class PaymentAnswer < BaseAnswer
      def question_text
        I18n.t("summary.questions.#{question}.question", **i18n_opts)
      end

      def answer_text
        simple_format(
          I18n.t(
            "summary.questions.#{question}.answers.description",
            amount: number_to_currency(value.amount, unit: '£', separator: '.', delimiter: ','),
            frequency: PaymentFrequencyType.to_phrase(value.frequency),
            tax_status: tax_status
          ),
          { class: 'govuk-body' }
        )
      end

      def tax_status
        val = value.respond_to?(:metadata) && value.metadata.dig('before_or_after_tax', 'value')
        t("summary.#{val}") if val
      end
    end
  end
end
