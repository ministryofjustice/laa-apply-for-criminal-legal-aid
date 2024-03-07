module Summary
  module Components
    class PaymentAnswer < BaseAnswer
      def to_partial_path
        'steps/submission/shared/money_answer'
      end
    end
  end
end
