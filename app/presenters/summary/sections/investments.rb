module Summary
  module Sections
    class Investments < Sections::BaseSection
      def show?
        capital && requires_full_capital
      end

      def answers # rubocop:disable Metrics/MethodLength
        if investments.empty?
          [
            Components::ValueAnswer.new(
              :has_investments, 'no',
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

      def requires_full_capital
        [
          CaseType::EITHER_WAY.to_s,
          CaseType::INDICTABLE.to_s,
          CaseType::ALREADY_IN_CROWN_COURT.to_s
        ].include?(crime_application.case.case_type)
      end
    end
  end
end
