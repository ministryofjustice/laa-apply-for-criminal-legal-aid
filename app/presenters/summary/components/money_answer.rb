module Summary
  module Components
    class MoneyAnswer < BaseAnswer
      def answer_text
        return unless value

        total = number_to_currency(value.to_s)
        total.sub(/\.00$/, '')
      end
    end
  end
end
