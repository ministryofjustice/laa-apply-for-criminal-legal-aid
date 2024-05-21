module Summary
  module Sections
    class Savings < Sections::BaseSection
      def show?
        shown_savings?
      end

      def answers
        return savings_list_component unless no_savings?

        [
          Components::ValueAnswer.new(
            :has_capital_savings, 'none',
            change_path: edit_steps_capital_saving_type_path
          )
        ]
      end

      def list?
        !no_savings?
      end

      private

      def savings_list_component
        Summary::Components::GroupedList.new(
          items: savings,
          group_by: :saving_type,
          item_component: Summary::Components::Saving,
          show_actions: editable?,
          show_record_actions: headless?
        )
      end

      def savings
        @savings ||= crime_application.savings
      end

      def shown_savings?
        capital.present? && (no_savings? || savings.present?)
      end

      def no_savings?
        return false if capital.has_no_savings.nil?

        YesNoAnswer.new(capital.has_no_savings).yes?
      end
    end
  end
end
