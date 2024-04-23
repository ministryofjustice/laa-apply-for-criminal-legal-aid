module Summary
  module Sections
    class Savings < Sections::BaseSection
      def show?
        shown_savings?
      end

      def answers
        if has_no_savings?
          [
            Components::ValueAnswer.new(
              :has_capital_savings, 'none',
              change_path: edit_steps_capital_savings_summary_path
            )
          ]
        else
          Summary::Components::GroupedList.new(
            items: savings,
            group_by: :saving_type,
            item_component: Summary::Components::Saving,
            show_actions: editable?,
            show_record_actions: headless?
          )
        end
      end

      def list?
        return false if savings.empty?

        true
      end

      private

      def savings
        @savings ||= crime_application.savings
      end

      def capital
        @capital ||= crime_application.capital
      end

      def shown_savings?
        capital.present? && (has_no_savings? || savings.present?)
      end

      def has_no_savings?
        return false if capital.has_no_savings.nil?

        YesNoAnswer.new(capital.has_no_savings).yes?
      end
    end
  end
end
