module Summary
  module Sections
    class Employments < Sections::BaseSection
      def answers
        return [] if employments.empty?

        Summary::Components::GroupedList.new(
          items: employments,
          group_by: :ownership_type,
          item_component: Summary::Components::Employment,
          show_actions: editable?,
          show_record_actions: headless?
        )
      end

      def list?
        return false if employments.empty?

        true
      end

      private

      def employments
        @employments ||= crime_application.employments
      end
    end
  end
end
