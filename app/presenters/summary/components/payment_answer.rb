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
            frequency: PaymentFrequencyType.to_phrase(value.frequency)
          ),
          { class: 'govuk-body' }
        )
      end
    end
  end
end
