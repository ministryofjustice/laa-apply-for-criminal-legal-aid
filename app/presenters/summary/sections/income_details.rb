module Summary
  module Sections
    class IncomeDetails < Sections::BaseSection
      def name
        :income_details
      end

      def show?
        income.present? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            :income_above_threshold, income.income_above_threshold,
            change_path: edit_steps_income_income_before_tax_path
          ),
        ].select(&:show?)
      end

      private

      def income
        @income ||= crime_application.income
      end
    end
  end
end
