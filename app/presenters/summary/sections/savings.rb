module Summary
  module Sections
    class Savings < Sections::BaseSection
      def show?
        !savings.empty?
      end

      def answers
        Summary::Components::GroupedList.new(
          items: savings,
          group_by: :saving_type,
          item_component: Summary::Components::Saving,
          show_actions: editable?,
          show_record_actions: headless?
        )
      end

      def list?
        true
      end

      private

      def savings
        @savings ||= crime_application.savings
      end
    end
  end
end
