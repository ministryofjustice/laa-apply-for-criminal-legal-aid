module Summary
  module Components
    class FreeTextAnswer < BaseAnswer
      def to_partial_path
        'steps/submission/shared/free_text_answer'
      end
    end
  end
end
