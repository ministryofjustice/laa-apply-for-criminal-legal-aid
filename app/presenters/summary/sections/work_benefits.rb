module Summary
  module Sections
    class WorkBenefits < Sections::BaseSection
      def show?
        income.applicant_other_work_benefit_received.present? && super
      end

      def answers # rubocop:disable Metrics/MethodLength
        answers = [
          Components::ValueAnswer.new(
            'employments.applicant_work_benefit_question', income.applicant_other_work_benefit_received,
            change_path: edit_steps_income_client_other_work_benefits_path
          )
        ]

        if income.applicant_other_work_benefit_received == 'yes' && work_benefits.present?
          answers << Components::PaymentAnswer.new(
            'employments.applicant_work_benefit_amount', work_benefits,
            change_path: edit_steps_income_client_other_work_benefits_path
          )
        end
        answers.select(&:show?)
      end

      def work_benefits
        crime_application.income_payments.work_benefits
      end
    end
  end
end
