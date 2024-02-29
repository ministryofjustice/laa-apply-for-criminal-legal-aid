module Summary
  module Sections
    class Savings < Sections::BaseSection
      def show?
        !crime_application.savings.empty?
      end

      def answers
        Summary::Components::GroupedList.new(
          items: savings,
          group_by: :saving_type,
          item_component: Summary::Components::SavingItem
        )
      end

      private

      def savings
        @savings ||= crime_application.savings.order(:created_at)
      end
    end
  end
end
