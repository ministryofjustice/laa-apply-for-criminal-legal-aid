module Summary
  module Sections
    class Savings < Sections::CapitalLoopBase
      private

      def records
        @records ||= crime_application.savings
      end

      def question
        :has_capital_savings
      end

      def edit_path
        edit_steps_capital_savings_summary_path
      end

      def list_component
        Summary::Components::GroupedList.new(
          items: records,
          group_by: :saving_type,
          item_component: Summary::Components::Saving,
          show_actions: editable?,
          show_record_actions: headless?
        )
      end
    end
  end
end
