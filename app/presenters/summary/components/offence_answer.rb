module Summary
  module Components
    class OffenceAnswer < BaseAnswer
      # This component receives as `value` a presented `charge`
      delegate :offence_name,
               :offence_class,
               :offence_dates,
               :complete?, to: :value

      def question_text
        render partial: 'steps/shared/charge', locals: { charge: value }
      end
    end
  end
end
