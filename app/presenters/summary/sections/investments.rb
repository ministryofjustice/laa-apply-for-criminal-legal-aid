module Summary
  module Sections
    class Investments < Sections::CapitalLoopBase
      def answers # rubocop:disable Metrics/MethodLength
        if records.empty?
          [
            Components::ValueAnswer.new(
              :has_investments, 'no',
              change_path: edit_steps_capital_investment_type_path
            )
          ]
        else
          Summary::Components::GroupedList.new(
            items: records,
            group_by: :investment_type,
            item_component: Summary::Components::Investment,
            show_actions: editable?,
            show_record_actions: headless?
          )
        end
      end

      private

      def records
        @records ||= crime_application.investments
      end
    end
  end
end
