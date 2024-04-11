module Summary
  module Sections
    class Properties < Sections::CapitalLoopBase
      private

      def records
        @records ||= crime_application.properties
      end

      def question
        :has_assets
      end

      def edit_path
        edit_steps_capital_property_type_path
      end

      def list_component
        Summary::Components::GroupedList.new(
          items: records,
          group_by: :property_type,
          item_component: Summary::Components::Property,
          show_actions: editable?,
          show_record_actions: headless?
        )
      end
    end
  end
end
