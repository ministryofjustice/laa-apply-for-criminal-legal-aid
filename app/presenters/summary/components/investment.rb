module Summary
  module Components
    class Investment < BaseRecord
      GROUP_BY = :investment_type
      alias investment record

      private

      def answers
        [
          Components::FreeTextAnswer.new(
            :description, investment.description
          ),
          Components::MoneyAnswer.new(
            :value, investment.value
          ),
          Components::ValueAnswer.new(
            :ownership_type, investment.ownership_type
          )
        ]
      end

      def name
        I18n.t(investment.investment_type, scope: [:summary, :sections, :investment])
      end

      def change_path
        edit_steps_capital_investments_path(investment_id: record.id)
      end

      def summary_path
        edit_steps_capital_investments_summary_path
      end

      def remove_path
        confirm_destroy_steps_capital_investments_path(investment_id: record.id)
      end
    end
  end
end
