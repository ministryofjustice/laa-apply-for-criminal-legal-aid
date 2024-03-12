module Summary
  module Components
    class Investment < BaseRecord
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
            :holder, investment.holder
          )
        ]
      end

      def name
        I18n.t(investment.investment_type, scope: [:summary, :sections, :investment])
      end

      def change_path
        edit_steps_capital_investments_path(id: record.crime_application_id, investment_id: record.id)
      end

      def remove_path
        confirm_destroy_steps_capital_investments_path(id: record.crime_application_id, investment_id: record.id)
      end
    end
  end
end
