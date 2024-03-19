module Summary
  module Sections
    class Properties < Sections::BaseSection
      def show?
        !properties.empty?
      end

      def answers
        Summary::Components::GroupedList.new(
          items: properties,
          group_by: :property_type,
          item_component: Summary::Components::Property,
          show_actions: editable?
        )
      end

      def list?
        true
      end

      private

      def properties
        @properties ||= crime_application.properties
      end
    end
  end
end
