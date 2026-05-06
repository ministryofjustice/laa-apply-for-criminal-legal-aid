module Summary
  module Components
    class OffenceTypeAndClassAnswer < BaseAnswer
      def answer_text
        safe_join([offence_type, offence_class])
      end

      private

      def offence_type
        tag.p(
          value.offence_name.presence,
          class: 'govuk-body'
        )
      end

      def offence_class
        return not_determined_tag unless value.offence_class

        tag.p(
          value.offence_class,
          class: 'govuk-caption-m'
        )
      end

      def not_determined_tag
        GovukComponent::TagComponent.new(
          text: absence_answer,
          colour: 'red'
        ).call
      end
    end
  end
end
