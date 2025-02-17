module Summary
  module Components
    class PercentageAnswer < BaseAnswer
      def answer_text
        number_to_percentage(value, strip_insignificant_zeros: true)
      end
    end
  end
end
