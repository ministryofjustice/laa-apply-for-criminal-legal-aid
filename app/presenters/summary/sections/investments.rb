module Summary
  module Sections
    class Investments < BaseCapitalRecordsSection
      private

      def has_no_records_component
        Components::ValueAnswer.new(
          :has_investments, has_records_answer,
          change_path: edit_steps_capital_investment_type_path
        )
      end

      def item_component_class
        Summary::Components::Investment
      end

      def records
        @records ||= capital.investments
      end

      def has_records_answer
        case capital.has_no_investments
        when 'yes'
          YesNoAnswer::NO
        when 'no'
          YesNoAnswer::YES
        else
          capital.has_no_investments
        end
      end
    end
  end
end
