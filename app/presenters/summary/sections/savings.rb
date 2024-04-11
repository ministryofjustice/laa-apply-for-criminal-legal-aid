module Summary
  module Sections
    class Savings < Sections::CapitalLoopBase
      def answers # rubocop:disable Metrics/MethodLength
        if records.empty?
          [
            Components::ValueAnswer.new(
              :has_capital_savings, 'no',
              change_path: edit_steps_capital_saving_type_path
            )
          ]
        else
          Summary::Components::GroupedList.new(
            items: records,
            group_by: :saving_type,
            item_component: Summary::Components::Saving,
            show_actions: editable?,
            show_record_actions: headless?
          )
        end
      end

      private

      def records
        @records ||= crime_application.savings
      end
    end
  end
end
