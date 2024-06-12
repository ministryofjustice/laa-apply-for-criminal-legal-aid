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

      def subject_type
        return SubjectType.new(:applicant) unless value.respond_to?(:ownership_type)

        @subject_type ||=
          if value.ownership_type.to_s == OwnershipType::PARTNER.to_s
            SubjectType.new(:partner)
          elsif value.ownership_type.to_s == OwnershipType::APPLICANT_AND_PARTNER.to_s
            SubjectType.new(:applicant_and_partner)
          else
            SubjectType.new(:applicant)
          end
      end
    end
  end
end
