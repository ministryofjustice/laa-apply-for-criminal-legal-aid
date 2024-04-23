module Summary
  module Sections
    class Investments < Sections::BaseSection
      def show?
        shown_investments?
      end

      def answers
        if has_no_investments?
          [
            Components::ValueAnswer.new(
              :has_investments, 'none',
              change_path: edit_steps_capital_investments_summary_path
            )
          ]
        else
          Summary::Components::GroupedList.new(
            items: investments,
            group_by: :investment_type,
            item_component: Summary::Components::Investment,
            show_actions: editable?,
            show_record_actions: headless?
          )
        end
      end

      def list?
        return false if investments.empty?

        true
      end

      private

      def investments
        @investments ||= crime_application.investments
      end

      def capital
        @capital ||= crime_application.capital
      end

      def shown_investments?
        capital.present? && (has_no_investments? || investments.present?)
      end

      def has_no_investments?
        return false if capital.has_no_investments.nil?

        YesNoAnswer.new(capital.has_no_investments).yes?
      end
    end
  end
end
