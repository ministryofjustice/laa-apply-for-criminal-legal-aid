module Summary
  module Components
    class OffenceTypeAnswer < BaseAnswer
      def answer_text
        tag.p(
          value.offence_name.presence,
          class: 'govuk-body'
        )
      end
    end
  end
end
