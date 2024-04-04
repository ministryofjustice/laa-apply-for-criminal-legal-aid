module Summary
  module Components
    class PercentageAnswer < BaseAnswer
      def answer_text
        number_to_percentage(value, precision: 2) if value
      end
    end
  end
end
