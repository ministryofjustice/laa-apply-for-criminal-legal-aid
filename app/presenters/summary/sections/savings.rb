module Summary
  module Sections
    class Savings < BaseCapitalRecordsSection
      def heading
        :savings_and_investments
      end

      private

      def has_no_records_component
        Components::ValueAnswer.new(
          :has_capital_savings, has_records_answer,
          change_path: edit_steps_capital_saving_type_path
        )
      end

      def item_component_class
        Summary::Components::Saving
      end

      def records
        @records ||= capital.savings
      end

      def has_records_answer
        case capital.has_no_savings
        when 'yes'
          YesNoAnswer::NO
        when 'no'
          YesNoAnswer::YES
        else
          capital.has_no_savings
        end
      end
    end
  end
end
