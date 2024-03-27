module Summary
  module Components
    class MoneyAnswer < BaseAnswer
      def answer_text
        number_to_currency(value) if value
      end
    end
  end
end
