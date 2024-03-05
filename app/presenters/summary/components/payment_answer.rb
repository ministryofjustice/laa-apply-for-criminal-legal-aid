module Summary
  module Components
    class PaymentAnswer < BaseAnswer
      def to_partial_path
        'steps/submission/shared/payment_answer'
      end
    end
  end
end
