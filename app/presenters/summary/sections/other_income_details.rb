module Summary
  module Sections
    class OtherIncomeDetails < Sections::BaseSection
      include TypeOfMeansAssessment

      def show?
        income.present? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            :manage_without_income, income.manage_without_income,
            change_path: edit_steps_income_manage_without_income_path,
            subject_type: manage_without_income_subject
          ),
          Components::FreeTextAnswer.new(
            :manage_other_details, income.manage_other_details,
            change_path: edit_steps_income_manage_without_income_path
          ),
        ].select(&:show?)
      end

      private

      def manage_without_income_subject
        return unless include_partner_in_means_assessment?

        SubjectType.new(:applicant_and_partner)
      end
    end
  end
end
