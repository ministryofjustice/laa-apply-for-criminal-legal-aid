module Summary
  module Components
    class ValueAnswer < BaseAnswer
      def answer_text
        I18n.t("summary.questions.#{question}.answers.#{value}")
      end
    end
  end
end
