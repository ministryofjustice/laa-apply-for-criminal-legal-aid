module Summary
  module Sections
    class Investments < Sections::BaseSection
      def show?
        !investments.empty?
      end

      def answers
        Summary::Components::GroupedList.new(
          items: investments,
          group_by: :investment_type,
          item_component: Summary::Components::Investment,
          show_actions: editable?
        )
      end

      def list?
        true
      end

      private

      def investments
        @investments ||= crime_application.investments
      end
    end
  end
end
