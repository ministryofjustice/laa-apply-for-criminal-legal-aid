module Summary
  module Sections
    class Businesses < Sections::BaseSection
      def show?
        return false if income.blank?

        businesses.any?
      end

      def answers
        Summary::Components::GroupedList.new(
          items: businesses,
          group_by: :business_type,
          item_component: Summary::Components::Business,
          show_actions: editable?,
          show_record_actions: headless?
        )
      end

      def list?
        true
      end

      private

      def businesses
        subject.businesses
      end
    end
  end
end
