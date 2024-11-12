module Summary
  module Components
    class ReferenceAnswer < BaseAnswer
      def answer_text
        value.to_s
      end
    end
  end
end
