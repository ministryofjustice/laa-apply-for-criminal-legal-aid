class EmploymentIncomePaymentsCalculator
  class << self
    def annualized_payments(crime_application)
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

    private

    def grouped_employments(employments)
      employments.select(&:complete?).group_by(&:ownership_type)
    end

    def annual_income(employments)
      employments.sum { |e| e.annualized_amount.value }
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
