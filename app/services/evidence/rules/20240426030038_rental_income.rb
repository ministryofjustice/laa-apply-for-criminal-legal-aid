module Evidence
  module Rules
    class RentalIncome < Rule
      include Evidence::RuleDsl

      key :income_rent_8
      group :income

      client do |_crime_application, applicant|
        applicant.income_payment(IncomePaymentType::RENT).present?
      end

      partner do |_crime_application, partner|
        partner.present? && partner.income_payment(IncomePaymentType::RENT).present?
      end
    end
  end
end
