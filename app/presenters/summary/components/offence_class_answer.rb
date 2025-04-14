module Summary
  module Components
    class OffenceClassAnswer < BaseAnswer
      def answer_text
        return offence_class if value.offence_class

        not_determined_tag
      end

      private

      def offence_class
        tag.p(
          value.offence_class,
          class: 'govuk-body'
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
