class EmploymentIncomePaymentsCalculator
  class << self
    def annualized_payments(crime_application) # rubocop:disable Metrics/MethodLength
      if single_employment_income?(crime_application.income)
        # singe employment for client and partner
        grouped_income_payments(crime_application.income_payments).map do |ownership_type, income_payments_array|
          {
            amount: annual_income(income_payments_array),
            income_tax: 0,
            national_insurance: 0,
            frequency: PaymentFrequencyType::ANNUALLY.to_s,
            ownership_type: ownership_type
          }
        end
      else
        # employments loop for client and partner
        grouped_employments(crime_application.employments).map do |ownership_type, employments_array|
          {
            amount: annual_income(employments_array),
            income_tax: annual_deduction(employments_array, :income_tax),
            national_insurance: annual_deduction(employments_array, :national_insurance),
            frequency: PaymentFrequencyType::ANNUALLY.to_s,
            ownership_type: ownership_type
          }
        end
      end
    end

    private

    def single_employment_income?(income)
      income.employment_status.include?(EmploymentStatus::EMPLOYED.to_s) &&
        income.income_above_threshold == YesNoAnswer::NO.to_s &&
        income.has_frozen_income_or_assets == YesNoAnswer::NO.to_s &&
        income.client_owns_property == YesNoAnswer::NO.to_s &&
        income.has_savings == YesNoAnswer::NO.to_s
    end

    def grouped_employments(employments)
      employments.select(&:complete?).group_by(&:ownership_type)
    end

    def grouped_income_payments(income_payments)
      income_payments.select { |ip| ip.payment_type == IncomePaymentType::EMPLOYMENT.to_s }.group_by(&:ownership_type)
    end

    def annual_income(payments)
      payments.sum { |e| e.annualized_amount.value }
    end

    def annual_deduction(employments, deduction_type)
      deductions = employments.map do |employment|
        employment.deductions.complete.select do |deduction|
          deduction.deduction_type == deduction_type.to_s
        end
      end.flatten
      deductions.sum { |d| d.annualized_amount.value }
    end
  end
end
