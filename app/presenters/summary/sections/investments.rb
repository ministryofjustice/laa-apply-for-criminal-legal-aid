module Summary
  module Sections
    class Investments < Sections::BaseSection
      def show?
        return false
        shown_investments?
      end

      # rubocop:disable Metrics/MethodLength
      def answers
        if no_investments?
          [
            Components::ValueAnswer.new(
              :has_investments, 'none',
              change_path: edit_steps_capital_investment_type_path
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
      # rubocop:enable Metrics/MethodLength

      def list?
        return false if investments.empty?

        true
      end

      private

      def investments
        @investments ||= crime_application.investments
      end

      def shown_investments?
        capital.present? && (no_investments? || investments.present?)
      end

      def no_investments?
        return false if capital.has_no_investments.nil?

        YesNoAnswer.new(capital.has_no_investments).yes?
      end
    end
  end
end
