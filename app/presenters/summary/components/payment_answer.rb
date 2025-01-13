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
            amount: number_to_currency(value.amount.to_s),
            frequency: PaymentFrequencyType.to_phrase(value.frequency),
            tax_status: tax_status
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

      def tax_status
        val = value.respond_to?(:metadata) && value.metadata.to_h.dig('before_or_after_tax', 'value')
        t("summary.#{val}") if val
      end
    end
  end
end
