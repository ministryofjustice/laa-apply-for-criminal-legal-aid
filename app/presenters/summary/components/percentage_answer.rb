module Summary
  module Components
    class PercentageAnswer < BaseAnswer
      def answer_text
        return unless value

        total = number_to_percentage(value.to_s, precision: 2)
        total.sub(/\.00%$/, '%')
      end
    end
  end
end
