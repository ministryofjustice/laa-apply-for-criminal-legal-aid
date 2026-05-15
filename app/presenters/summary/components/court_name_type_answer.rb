module Summary
  module Components
    class CourtNameTypeAnswer < BaseAnswer
      def answer_text
        tag.p(
          value.presence,
          class: 'govuk-body',
          lang: 'en'
        )
      end
    end
  end
end
