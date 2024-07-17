module Evidence
  module Rules
    class InterestAndInvestments < Rule
      include Evidence::RuleDsl

      key :income_investments_7
      group :income

      client do |_crime_application, applicant|
        applicant.income_payment(IncomePaymentType::INTEREST_INVESTMENT).present?
      end

      partner do |_crime_application, partner|
        partner.present? &&
          partner.income_payment(IncomePaymentType::INTEREST_INVESTMENT).present?
      end
    end
  end
end
