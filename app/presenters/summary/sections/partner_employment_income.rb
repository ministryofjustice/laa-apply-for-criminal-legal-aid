module Summary
  module Sections
    class PartnerEmploymentIncome < Sections::BaseSection
      def show?
        income.present? && employment_income.present?
      end

      def answers
        [
          Components::PaymentAnswer.new(
            :partner_employment_income, employment_income,
            change_path: edit_steps_income_partner_employment_income_path
          )
        ]
      end

      def employment_income
        crime_application
          .income_payments
          .detect { |payment| (payment.payment_type == IncomePaymentType::EMPLOYMENT.to_s) && (payment.ownership_type == OwnershipType::PARTNER.to_s) } # rubocop:disable Layout/LineLength
      end
    end
  end
end
