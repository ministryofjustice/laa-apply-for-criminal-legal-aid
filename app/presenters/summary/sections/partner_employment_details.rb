module Summary
  module Sections
    class PartnerEmploymentDetails < Sections::BaseSection
      include HasDynamicSubject

      def show?
        income.present? &&
          MeansStatus.include_partner?(crime_application) &&
          income.partner_employment_status.present? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            :partner_employment_status, IncomePresenter.present(income).partner_employment_status_text,
            change_path: edit_steps_income_partner_employment_status_path
          ),
          Components::ValueAnswer.new(
            :partner_in_armed_forces, income.partner_in_armed_forces,
            change_path: edit_steps_income_armed_forces_path(subject: 'partner')
          ),
        ].flatten.select(&:show?)
      end

      def subject_type
        SubjectType.new(:partner)
      end
    end
  end
end
