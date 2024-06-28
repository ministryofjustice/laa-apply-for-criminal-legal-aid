module Summary
  module Sections
    class EmploymentIncome < Sections::BaseSection
      include TypeOfMeansAssessment

      def show?
        income.employment_status.include?('employed')
      end

      def answers
        [
          Components::PaymentAnswer.new(
            :employment_income, employment_income,
            change_path: edit_steps_income_client_employment_income_path
          )
        ]
      end

      def employment_income
        crime_application
          .income_payments
          .detect { |payment| (payment.payment_type == IncomePaymentType::EMPLOYMENT.to_s) && (payment.ownership_type == OwnershipType::APPLICANT.to_s) } # rubocop:disable Layout/LineLength
      end
    end
  end
end



if employment_status == employed

  if requires_full_means_assessment?
    
  end

else

end