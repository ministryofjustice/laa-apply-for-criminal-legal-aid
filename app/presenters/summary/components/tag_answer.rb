module Summary
  module Components
    class TagAnswer < BaseAnswer
      def answer_text
        answer = I18n.t("summary.questions.#{question}.answers.#{value}")
        GovukComponent::TagComponent.new(
          text: answer[:value],
          colour: answer[:colour]
        ).call
      end
    end
  end
end
