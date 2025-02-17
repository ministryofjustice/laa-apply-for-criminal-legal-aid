module Summary
  module Components
    class MoneyAnswer < BaseAnswer
      def answer_text
        number_to_currency(value.to_s, strip_insignificant_zeros: true)
      end
    end
  end
end
