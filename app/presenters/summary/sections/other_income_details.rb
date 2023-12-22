module Summary
  module Sections
    class OtherIncomeDetails < Sections::BaseSection
      def show?
        income.present? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            :manage_without_income, income.manage_without_income,
            change_path: edit_steps_income_manage_without_income_path
          ),
          Components::FreeTextAnswer.new(
            :manage_other_details, income.manage_other_details,
            change_path: edit_steps_income_manage_without_income_path
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
