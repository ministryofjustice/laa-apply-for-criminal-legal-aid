module Summary
  module Components
    class SavingAnswer < BaseAnswer
      # This component receives as `value` a presented `charge`
      delegate :provider_name,
               :account_number,
               :sort_code, to: :value

      def to_partial_path
        'steps/submission/shared/saving_answer'
      end
    end
  end
end
