module Summary
  module Sections
    class Properties < Sections::CapitalLoopBase
      def answers # rubocop:disable Metrics/MethodLength
        if records.empty?
          [
            Components::ValueAnswer.new(
              :has_assets, 'no',
              change_path: edit_steps_capital_property_type_path
            )
          ]
        else
          Summary::Components::GroupedList.new(
            items: records,
            group_by: :property_type,
            item_component: Summary::Components::Property,
            show_actions: editable?,
            show_record_actions: headless?
          )
        end
      end

      private

      def records
        @records ||= crime_application.properties
      end
    end
  end
end
