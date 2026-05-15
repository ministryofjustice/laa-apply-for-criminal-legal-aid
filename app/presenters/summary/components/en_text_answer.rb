module Summary
  module Components
    class EnTextAnswer < BaseAnswer
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
