module Summary
  module Components
    class OffenceTypeAndClassAnswer < BaseAnswer
      def answer_text
        return offence_name unless value.offence_class

        safe_join [offence_name, offence_class]
      end

      private

      def offence_name
        tag.p(
          value.offence_name.presence,
          class: 'govuk-body govuk-!-margin-bottom-1'
        )
      end

      def offence_class
        tag.p(
          value.offence_class,
          class: 'govuk-caption-m govuk-!-margin-bottom-2 govuk-!-margin-top-0'
        )
      end
    end
  end
end
