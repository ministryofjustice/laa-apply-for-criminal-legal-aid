module Summary
  module Sections
    class Investments < Sections::CapitalLoopBase
      private

      def records
        @records ||= crime_application.investments
      end

      def question
        :has_investments
      end

      def edit_path
        edit_steps_capital_investment_type_path
      end

      def list_component
        Summary::Components::GroupedList.new(
          items: records,
          group_by: :investment_type,
          item_component: Summary::Components::Investment,
          show_actions: editable?,
          show_record_actions: headless?
        )
      end
    end
  end
end
