module Summary
  module Sections
    class PartnerWorkBenefits < Sections::BaseSection
      include HasDynamicSubject

      def show?
        income.present? && income.partner_other_work_benefit_received.present?
      end

      def answers # rubocop:disable Metrics/MethodLength
        answers = [
          Components::ValueAnswer.new(
            :partner_work_benefits, income.partner_other_work_benefit_received,
            change_path: edit_steps_income_partner_other_work_benefits_path
          )
        ]

        if income.partner_other_work_benefit_received == YesNoAnswer::YES.to_s
          answers << Components::PaymentAnswer.new(
            :partner_work_benefits_payment, work_benefits,
            change_path: edit_steps_income_partner_other_work_benefits_path
          )
        end

        answers
      end

      def work_benefits
        income.partner_work_benefits
      end

      private

      def subject_type
        SubjectType.new(:partner)
      end
    end
  end
end
