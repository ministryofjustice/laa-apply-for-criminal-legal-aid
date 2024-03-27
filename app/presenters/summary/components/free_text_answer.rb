module Summary
  module Components
    class FreeTextAnswer < BaseAnswer
      def answer_text
        simple_format(value.presence || absence_answer)
      end
    end
  end
end
