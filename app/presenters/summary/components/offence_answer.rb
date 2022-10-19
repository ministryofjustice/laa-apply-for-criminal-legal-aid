module Summary
  module Components
    class OffenceAnswer < BaseAnswer
      # This component receives as `value` a presented `charge`
      delegate :offence_name,
               :offence_class,
               :offence_dates, to: :value

      def value?
        super && value.complete?
      end

      def to_partial_path
        'steps/submission/shared/offence_answer'
      end
    end
  end
end
