module Summary
  module Sections
    class Savings < Sections::BaseSection
      def show?
        capital && requires_full_capital
      end

      def answers # rubocop:disable Metrics/MethodLength
        if savings.empty?
          [
            Components::ValueAnswer.new(
              :has_capital_savings, 'no',
              change_path: edit_steps_capital_saving_type_path
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
